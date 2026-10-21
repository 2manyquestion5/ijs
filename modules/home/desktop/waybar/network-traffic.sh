#!/usr/bin/env bash

# Waybar network traffic
#
# PURPOSE: Show upload/download rates for the first IPv4 default-route interface.
# ROLE: Invoked periodically by Waybar; the first valid sample displays zero.
# CUSTOMIZATION: Route selection may need adapting for other network setups.
# SECURITY: Trust the session's private runtime directory, never shared /tmp state.
# Processes running as this same user remain inside that trust boundary.

set -o pipefail
export LC_ALL=C
umask 077

# Bash arithmetic can evaluate expressions. Accept only canonical decimal numbers
# up to its signed 64-bit limit; leading zeroes could otherwise mean octal.
is_uint() {
    local value=$1
    [[ $value =~ ^(0|[1-9][0-9]{0,18})$ ]] || return 1
    if [[ ${#value} == 19 && $value > 9223372036854775807 ]]; then
        return 1
    fi
    return 0
}

private_directory() {
    [[ -d $1 && ! -L $1 && -O $1 ]] &&
        [[ $(stat -c '%a' -- "$1" 2>/dev/null) == 700 ]]
}

state=
unavailable() {
    # A missing observation breaks the sampling interval. Do not reuse it later.
    if [[ -n $state && -f $state && ! -L $state && -O $state ]]; then
        rm -f -- "$state"
    fi
    printf '↑ —  ↓ —\n'
    exit 0
}

runtime=${XDG_RUNTIME_DIR:-}
[[ $runtime == /* ]] && private_directory "$runtime" || unavailable
state_dir="$runtime/ijs-waybar-network"
mkdir -m 700 -- "$state_dir" 2>/dev/null || : # An existing private directory is OK.
private_directory "$state_dir" || unavailable
state="$state_dir/sample"

# Refuse unexpected files rather than following links or blocking on a FIFO.
if [[ -e $state || -L $state ]]; then
    [[ -f $state && ! -L $state && -O $state ]] || unavailable
fi

iface=$(ip -o -4 route show default 2>/dev/null | awk '
    $1 == "default" {
        for (i = 2; i < NF; i++)
            if ($i == "dev") { print $(i + 1); exit }
    }
') || unavailable
[[ $iface =~ ^[a-zA-Z0-9_.:-]+$ && $iface != . && $iface != .. ]] || unavailable

rx=$(cat -- "/sys/class/net/$iface/statistics/rx_bytes" 2>/dev/null) || unavailable
tx=$(cat -- "/sys/class/net/$iface/statistics/tx_bytes" 2>/dev/null) || unavailable
now=$(date +%s) || unavailable
is_uint "$rx" && is_uint "$tx" && is_uint "$now" || unavailable

down=0
up=0
# Read data, never source/eval it. Require one record with no extra fields.
if [[ -f $state ]] && sample=$(cat -- "$state" 2>/dev/null) &&
    [[ $sample != *$'\n'* ]] &&
    read -r old_iface old_rx old_tx old_time extra <<< "$sample" &&
    [[ -z $extra && $old_iface == "$iface" ]] &&
    is_uint "$old_rx" && is_uint "$old_tx" && is_uint "$old_time"; then
    # Interface/counter resets and non-advancing clocks start a new baseline.
    # Ordered, bounded operands keep both subtractions within the signed range.
    # Dividing the byte delta directly avoids overflow from multiplying by time.
    if (( now > old_time && rx >= old_rx && tx >= old_tx )); then
        elapsed=$((now - old_time))
        down=$(((rx - old_rx) / elapsed))
        up=$(((tx - old_tx) / elapsed))
    fi
fi

# Readers see either the old complete record or the new one, never a partial write.
tmp=$(mktemp "$state_dir/sample.XXXXXX") || unavailable
trap 'rm -f -- "$tmp"' EXIT
if ! printf '%s %s %s %s\n' "$iface" "$rx" "$tx" "$now" > "$tmp" ||
    ! mv -fT -- "$tmp" "$state"; then
    unavailable
fi

human() {
    # awk uses floating point for the rounded display only, not rate arithmetic.
    awk -v value="$1" 'BEGIN {
        if (value >= 1048576) printf "%.1fM", value / 1048576
        else if (value >= 1024) printf "%.0fK", value / 1024
        else printf "%dB", value
    }'
}

printf '↑ %s  ↓ %s\n' "$(human "$up")" "$(human "$down")"
