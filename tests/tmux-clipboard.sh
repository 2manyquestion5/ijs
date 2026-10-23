#!/usr/bin/env bash
# PURPOSE: Check generated tmux configs and terminal copying on isolated servers.
# CONSUMER: The tmux-clipboard Nix check; pass Wayland and terminal config paths.
# CUSTOMIZATION: Extend only when changing clipboard behavior; no desktop is required.
# SECURITY: Never connects to an existing server or invokes the real Wayland clipboard.
set -euo pipefail
unset TMUX TMUX_PANE

export TMUX_TMPDIR
TMUX_TMPDIR=$(mktemp -d)
chmod 700 "$TMUX_TMPDIR"
trap 'tmux -L ijs-wayland kill-server 2>/dev/null || true
      tmux -L ijs-terminal kill-server 2>/dev/null || true
      rm -rf "$TMUX_TMPDIR"' EXIT

tmux -L ijs-wayland -f "$1" new-session -d -s test 'sleep 300'
tmux -L ijs-terminal -f "$2" new-session -d -s test 'printf "ijs-portability\n"; sleep 300'

for server in ijs-wayland ijs-terminal; do
  test "$(tmux -L "$server" show-option -gv prefix)" = C-Space
  test "$(tmux -L "$server" show-window-option -gv mode-keys)" = vi
  for key in y Enter; do
    binding=$(tmux -L "$server" list-keys -T copy-mode-vi |
      grep -E "^bind-key[[:space:]]+-T copy-mode-vi[[:space:]]+$key[[:space:]]")
    if [ "$server" = ijs-wayland ]; then
      grep -F 'copy-pipe-and-cancel' <<< "$binding"
      grep -E '/nix/store/[^ /]+-wl-clipboard[^ /]*/bin/wl-copy' <<< "$binding"
    else
      grep -F 'copy-selection-and-cancel' <<< "$binding"
      if grep -F 'wl-copy' <<< "$binding"; then exit 1; fi
    fi
  done
done
test "$(tmux -L ijs-terminal show-option -sv set-clipboard)" = off

# Wait for pane output before selecting its first line and pressing each bound key.
for attempt in $(seq 1 50); do
  if tmux -L ijs-terminal capture-pane -p | grep -q '^ijs-portability$'; then break; fi
  sleep 0.1
done
for key in y Enter; do
  tmux -L ijs-terminal copy-mode
  tmux -L ijs-terminal send-keys -X history-top
  tmux -L ijs-terminal send-keys -X start-of-line
  tmux -L ijs-terminal send-keys -X begin-selection
  tmux -L ijs-terminal send-keys -X end-of-line
  tmux -L ijs-terminal send-keys "$key"
  test "$(tmux -L ijs-terminal show-buffer)" = ijs-portability
  tmux -L ijs-terminal delete-buffer
done
printf 'Both configs loaded; y and Enter copied into the isolated tmux buffer.\n'
