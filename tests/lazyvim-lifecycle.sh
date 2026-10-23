#!/usr/bin/env bash
# PURPOSE: Test Home Manager's actual file transitions and the replacement editor.
# CONSUMER: The lazyvim-lifecycle Nix check supplies generated phases and homes.
# CUSTOMIZATION: Exercise application ownership, not package/profile activation.
# SECURITY: Run only inside the check's disposable home; preserve unmanaged data.
set -euo pipefail

test_home=${IJS_TEST_HOME:?Run through the lazyvim-lifecycle Nix check}
# Refuse to run these file transitions outside the check's temporary home.
[[ $HOME == "$test_home" && $test_home == "$TMPDIR"/ijs-lazyvim-lifecycle.* ]]
enabled=$1
disabled=$2
plain=$3
enabled_phase=$4
disabled_phase=$5
plain_phase=$6
plain_nvim=$7

mkdir -p "$HOME/.config/nvim" "$HOME/.local/share/nvim/lazy" "$HOME/.cache" "$HOME/.local/state"
printf 'keep user configuration\n' > "$HOME/.config/nvim/user-note.txt"
printf 'keep user data\n' > "$HOME/.local/share/nvim/user-state.txt"
printf 'keep cached data\n' > "$HOME/.cache/user-note.txt"

# An unmanaged initialization file must block linking, never be overwritten.
printf 'keep user init\n' > "$HOME/.config/nvim/init.lua"
if newGenPath=$enabled bash "$enabled_phase" > "$HOME/collision.log" 2>&1; then
  printf 'FAIL: an unmanaged init.lua was accepted\n' >&2
  exit 1
fi
grep -Fx 'keep user init' "$HOME/.config/nvim/init.lua"
mv "$HOME/.config/nvim/init.lua" "$HOME/.config/nvim/user-init.lua.saved"

newGenPath=$enabled bash "$enabled_phase"
test -L "$HOME/.config/nvim/init.lua"
test -L "$HOME/.config/nvim/lua/plugins/nixDependencies.lua"

oldGenPath=$enabled newGenPath=$disabled bash "$disabled_phase"
test ! -e "$HOME/.config/nvim/init.lua"
test ! -L "$HOME/.config/nvim/init.lua"
test ! -e "$HOME/.config/nvim/lua/plugins/nixDependencies.lua"
test ! -L "$HOME/.config/nvim/lua/plugins/nixDependencies.lua"

oldGenPath=$disabled newGenPath=$enabled bash "$enabled_phase"
oldGenPath=$enabled newGenPath=$plain bash "$plain_phase"
test -L "$HOME/.config/nvim/init.lua"
test ! -e "$HOME/.config/nvim/lua/plugins/nixDependencies.lua"
test ! -L "$HOME/.config/nvim/lua/plugins/nixDependencies.lua"
test ! -e "$HOME/.local/share/nvim/site/parser"
test ! -L "$HOME/.local/share/nvim/site/parser"
test ! -L "$HOME/.local/share/nvim/site/queries"

timeout --kill-after=5s 30s "$plain_nvim" --headless \
  '+lua assert(vim.g.ijs_plain_editor == true); assert(package.loaded["lazy"] == nil); assert(vim.fn.exists(":Lazy") == 0)' +qa

grep -Fx 'keep user configuration' "$HOME/.config/nvim/user-note.txt"
grep -Fx 'keep user init' "$HOME/.config/nvim/user-init.lua.saved"
grep -Fx 'keep user data' "$HOME/.local/share/nvim/user-state.txt"
grep -Fx 'keep cached data' "$HOME/.cache/user-note.txt"
printf 'PASS: disable/replacement through Home Manager file phases; unmanaged files preserved\n'
