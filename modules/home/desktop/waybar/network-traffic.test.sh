#!/usr/bin/env bash
# PURPOSE: Exercise network sampling and hostile state without a live desktop.
# ROLE: Run with bash modules/home/desktop/waybar/network-traffic.test.sh.
# CUSTOMIZATION: Add cases below; fake commands supply routes, counters and time.
# SECURITY: All writable fixtures live in a disposable private directory. No real
# network settings, sysfs files, desktop configuration or services are changed.

set -euo pipefail
export LC_ALL=C

widget_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
test_root=$(mktemp -d)
trap 'rm -rf -- "$test_root"' EXIT
export TEST_REAL_CAT
TEST_REAL_CAT=$(command -v cat)
export TEST_REAL_MKTEMP TEST_REAL_MV
TEST_REAL_MKTEMP=$(command -v mktemp)
TEST_REAL_MV=$(command -v mv)
export TEST_MARKER="$test_root/command-executed"
mkdir "$test_root/bin" "$test_root/store"

cat > "$test_root/bin/ip" <<'SH'
#!/usr/bin/env bash
[[ $* == '-o -4 route show default' && $TEST_IP_FAIL == 0 ]] || exit 1
printf '%s\n' "$TEST_ROUTES"
SH
cat > "$test_root/bin/cat" <<'SH'
#!/usr/bin/env bash
[[ ${1:-} == -- ]] && shift
case ${1:-} in
    /sys/class/net/*/statistics/rx_bytes)
        [[ $TEST_RX_FAIL == 0 ]] || exit 1
        printf '%s\n' "$TEST_RX" ;;
    /sys/class/net/*/statistics/tx_bytes)
        [[ $TEST_TX_FAIL == 0 ]] || exit 1
        printf '%s\n' "$TEST_TX" ;;
    *) exec "$TEST_REAL_CAT" -- "$@" ;;
esac
SH
cat > "$test_root/bin/date" <<'SH'
#!/usr/bin/env bash
[[ $* == +%s && $TEST_DATE_FAIL == 0 ]] || exit 1
printf '%s\n' "$TEST_NOW"
SH
cat > "$test_root/bin/mktemp" <<'SH'
#!/usr/bin/env bash
[[ $TEST_MKTEMP_FAIL == 0 ]] || exit 1
exec "$TEST_REAL_MKTEMP" "$@"
SH
cat > "$test_root/bin/mv" <<'SH'
#!/usr/bin/env bash
[[ $TEST_MV_FAIL == 0 ]] || exit 1
exec "$TEST_REAL_MV" "$@"
SH
chmod 700 "$test_root/bin/"*

# Home Manager's source + executable=true copies/links these bytes and sets the
# executable bit. Exercise a read-only executable copy reached through a symlink,
# as well as the source via bash. This simulates file installation, not a Nix build.
cp "$widget_dir/network-traffic.sh" "$test_root/store/network-traffic.sh"
chmod 555 "$test_root/store/network-traffic.sh"
mkdir -p "$test_root/home/.config/waybar"
ln -s "$test_root/store/network-traffic.sh" \
    "$test_root/home/.config/waybar/network-traffic.sh"
export PATH="$test_root/bin:$PATH"

checks=0
fail() { printf 'FAIL (%s): %s\n' "$mode" "$*" >&2; exit 1; }

run_widget() {
    if [[ $mode == source ]]; then
        bash "$widget_dir/network-traffic.sh"
    else
        "$test_root/home/.config/waybar/network-traffic.sh"
    fi
}

expect() {
    local label=$1 expected=$2 actual
    actual=$(run_widget 2> "$test_root/stderr") || fail "$label: nonzero exit"
    [[ $actual == "$expected" ]] || fail "$label: got '$actual', wanted '$expected'"
    [[ ! -s $test_root/stderr ]] || fail "$label: unexpected stderr"
    [[ ! -e $TEST_MARKER ]] || fail "$label: state executed a command"
    checks=$((checks + 1))
}

reset_fixture() {
    rm -rf -- "$test_root/runtime" "$test_root/runtime-link"
    export XDG_RUNTIME_DIR="$test_root/runtime"
    mkdir -m 700 "$XDG_RUNTIME_DIR"
    state_dir="$XDG_RUNTIME_DIR/ijs-waybar-network"
    state="$state_dir/sample"
    export TEST_ROUTES='default via 192.0.2.1 dev eth0'
    export TEST_RX=100 TEST_TX=200 TEST_NOW=100
    export TEST_IP_FAIL=0 TEST_RX_FAIL=0 TEST_TX_FAIL=0 TEST_DATE_FAIL=0
    export TEST_MKTEMP_FAIL=0 TEST_MV_FAIL=0
}

set_state() {
    printf '%s %s %s %s\n' "$@" > "$state"
}

zero='↑ 0B  ↓ 0B'
missing='↑ —  ↓ —'
max=9223372036854775807
# The payload contains no whitespace, so it reaches numeric validation as one
# field. If arithmetic evaluated it, touch would create only our test marker.
payload='a[$(touch${IFS}"$TEST_MARKER")]'

for mode in source installed; do
    reset_fixture
    expect 'first sample' "$zero"
    [[ $(stat -c '%a' "$state_dir") == 700 ]] || fail 'directory is not private'
    [[ $(stat -c '%a' "$state") == 600 ]] || fail 'state is not private'
    [[ $("$TEST_REAL_CAT" "$state") == 'eth0 100 200 100' ]] || fail 'wrong baseline'

    TEST_NOW=102 TEST_RX=1124 TEST_TX=2248
    expect 'known byte and kilobyte rates' '↑ 1K  ↓ 512B'
    TEST_NOW=104 TEST_RX=2098276 TEST_TX=4196552
    expect 'megabyte rates' '↑ 2.0M  ↓ 1.0M'
    if compgen -G "$state_dir/sample.*" > /dev/null; then fail 'temporary file left behind'; fi

    TEST_ROUTES='default dev wlan0 metric 600'
    TEST_NOW=106
    expect 'interface change without a gateway' "$zero"
    TEST_ROUTES='default via 192.0.2.1 dev eth0'
    TEST_NOW=108
    expect 'returning interface starts fresh' "$zero"
    TEST_NOW=110 TEST_RX=1 TEST_TX=2
    expect 'counter reset' "$zero"
    TEST_RX=10 TEST_TX=20
    expect 'unchanged clock' "$zero"
    TEST_NOW=109
    expect 'clock moving backwards' "$zero"

    set_state eth0 0 0 0
    TEST_NOW=1 TEST_RX=$max TEST_TX=$max
    expect 'maximum signed delta divided by one' '↑ 8796093022208.0M  ↓ 8796093022208.0M'
    set_state eth0 0 0 0
    TEST_NOW=$max
    expect 'maximum signed elapsed interval' '↑ 1B  ↓ 1B'

    TEST_RX=100 TEST_TX=200 TEST_NOW=100
    # Exercise each untrusted old field, including expression and overflow input.
    for bad in '' -1 01 1+2 "$payload" 9223372036854775808 999999999999999999999999; do
        set_state eth0 "$bad" 0 0
        expect 'invalid old RX' "$zero"
        set_state eth0 0 "$bad" 0
        expect 'invalid old TX' "$zero"
        set_state eth0 0 0 "$bad"
        expect 'invalid old timestamp' "$zero"
    done
    printf 'eth0 0 0 0 extra\n' > "$state"
    expect 'extra state field' "$zero"
    printf 'eth0 0 0 0\neth0 1 1 1\n' > "$state"
    expect 'multiple state records' "$zero"

    # Missing or invalid current data must remove the old baseline.
    for bad in '' -1 01 1+2 "$payload" 9223372036854775808; do
        set_state eth0 0 0 0
        TEST_RX=$bad
        expect 'invalid current RX' "$missing"
        [[ ! -e $state ]] || fail 'invalid RX retained a baseline'
    done
    TEST_RX=100 TEST_TX=$payload
    expect 'invalid current TX' "$missing"
    TEST_TX=200 TEST_NOW=$payload
    expect 'invalid current timestamp' "$missing"
    TEST_NOW=100

    for failure in TEST_IP_FAIL TEST_RX_FAIL TEST_TX_FAIL TEST_DATE_FAIL; do
        set_state eth0 0 0 0
        printf -v "$failure" '%s' 1
        expect "$failure" "$missing"
        [[ ! -e $state ]] || fail "$failure retained a baseline"
        printf -v "$failure" '%s' 0
    done
    set_state eth0 0 0 0
    TEST_ROUTES=
    expect 'no default route' "$missing"
    [[ ! -e $state ]] || fail 'no route retained a baseline'
    TEST_ROUTES='default dev ../../outside'
    expect 'unsafe interface name' "$missing"
    TEST_ROUTES='default dev eth0'
    expect 'valid data after missing samples starts fresh' "$zero"

    for failure in TEST_MKTEMP_FAIL TEST_MV_FAIL; do
        set_state eth0 0 0 0
        printf -v "$failure" '%s' 1
        expect "$failure" "$missing"
        [[ ! -e $state ]] || fail "$failure retained a baseline"
        if compgen -G "$state_dir/sample.*" > /dev/null; then fail "$failure left a temporary file"; fi
        printf -v "$failure" '%s' 0
    done
    expect 'recovery after state-write failure' "$zero"

    # Neither a symlink target nor a FIFO should be read or overwritten.
    printf 'untouched\n' > "$test_root/target"
    rm "$state"
    ln -s "$test_root/target" "$state"
    expect 'symlinked state' "$missing"
    [[ $("$TEST_REAL_CAT" "$test_root/target") == untouched ]] || fail 'symlink target changed'
    rm "$state"
    mkfifo "$state"
    expect 'FIFO state' "$missing"
    rm "$state"

    reset_fixture
    mkdir -m 755 "$state_dir"
    expect 'unsafe existing widget directory' "$missing"
    [[ ! -e $state ]] || fail 'used unsafe widget directory'
    [[ $(stat -c '%a' "$state_dir") == 755 ]] || fail 'changed existing permissions'
    reset_fixture
    ln -s "$test_root/store" "$state_dir"
    expect 'symlinked widget directory' "$missing"
    reset_fixture
    chmod 755 "$XDG_RUNTIME_DIR"
    expect 'unsafe runtime permissions' "$missing"
    [[ ! -e $state_dir ]] || fail 'wrote under unsafe runtime directory'
    chmod 700 "$XDG_RUNTIME_DIR"
    ln -s "$XDG_RUNTIME_DIR" "$test_root/runtime-link"
    XDG_RUNTIME_DIR="$test_root/runtime-link"
    expect 'symlinked runtime directory' "$missing"
    XDG_RUNTIME_DIR=relative/path
    expect 'relative runtime directory' "$missing"
    XDG_RUNTIME_DIR="$test_root/absent"
    expect 'nonexistent runtime directory' "$missing"
    unset XDG_RUNTIME_DIR
    expect 'unset runtime directory' "$missing"

    printf 'PASS: %s execution\n' "$mode"
done

cmp "$widget_dir/network-traffic.sh" "$test_root/store/network-traffic.sh"
printf 'PASS: %s output checks, plus state, permission and cleanup assertions\n' "$checks"
