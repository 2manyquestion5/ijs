# Tmux terminal multiplexer
#
# PURPOSE: Preserves the existing copy-mode, vi-navigation and plugin workflow.
# ROLE: User-level Home Manager module with a shared resolved theme.
# CUSTOMIZATION: Review keybindings before changing them; they are part of the user environment.

{ pkgs, theme, ... }:

  {

  programs.tmux = {
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

        #Copy from tmux directly to wayland clipboard
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "wl-copy"
      bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel "wl-co>
    '';

    };

}
