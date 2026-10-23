# Tmux terminal multiplexer
#
# PURPOSE: Preserves the existing copy-mode, vi-navigation and plugin workflow.
# ROLE: User-level Home Manager module with a shared resolved theme.
# CUSTOMIZATION: Review keybindings before changing them; they are part of the user environment.
# SECURITY: Wayland copying is the default; terminal-only users can keep copies inside tmux.

{ config, lib, pkgs, theme, ... }:

{
  options.ijs.tmux.waylandClipboard.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Copy tmux selections to Wayland; otherwise use only tmux's paste buffer.";
  };

  config.programs.tmux = {
    enable = true;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    prefix = "C-Space";
    clock24 = true;

    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      catppuccin
    ];

    extraConfig = ''
      set -g base-index 1
      setw -g pane-base-index 1
      set -sg escape-time 0

        #true color support for LazyVim / terminal themes
        set -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"

        # Catappuccin theme
        set -g @catppuccin_flavor "${theme.catppuccinFlavor}"

      ${if config.ijs.tmux.waylandClipboard.enable then ''
        # Copy the selection to the Wayland clipboard and leave copy mode.
        bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
        bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "${pkgs.wl-clipboard}/bin/wl-copy"
      '' else ''
        # A terminal-only host has no Wayland clipboard; retain tmux's paste buffer.
        # Also disable terminal clipboard escape sequences (OSC 52).
        set -s set-clipboard off
        bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
        bind-key -T copy-mode-vi Enter send-keys -X copy-selection-and-cancel
      ''}
    '';

    };

}
