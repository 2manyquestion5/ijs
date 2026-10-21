# Niri preference adapter
#
# PURPOSE: Converts normalized portable bindings and input into Niri KDL.
# ROLE: Loaded by the translator and reused across compatible users.
# CUSTOMIZATION: Review emitted KDL when adding a new shared action.

# =============================================================================
# NIRI ADAPTER
# =============================================================================
#
# Translates portable preferences into native Niri KDL.
#
# The central translator supplies:
#   - User preferences
#   - Nixpkgs
#   - Shared validation and translation functions
#
# This adapter owns Niri-specific actions, not user preferences.
#
# =============================================================================

{ lib, pkgs, preferences, translate }:

let
  bindings = translate.validateBindings preferences.bindings;
  input = preferences.input;
  apps = preferences.applications;

  # Shared session actions are independent of the translator.
  session = import ../../actions/session.nix { inherit lib pkgs; };

  # Niri uses different capitalization and "Mod" instead of "SUPER".
  key = value:
    lib.concatStringsSep "+" (
      map (part:
        {
          SUPER = "Mod";
          SHIFT = "Shift";
          CTRL = "Ctrl";
          ALT = "Alt";
          ESCAPE = "Escape";
          SPACE = "Space";
          TAB = "Tab";
          PRINT = "Print";
          LEFT = "Left";
          RIGHT = "Right";
          UP = "Up";
          DOWN = "Down";
        }.${part} or part
      ) (lib.splitString "+" value)
    );

  application = name:
    let app = apps.${name};
    in lib.getExe' app.package app.executable;

  # Run through a shell when commands contain arguments or pipelines.
  spawn = command:
    ''spawn "sh" "-c" ${builtins.toJSON command};'';

  command = category: action:
    let
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";
      playerctl = lib.getExe pkgs.playerctl;
      brightness = lib.getExe pkgs.brightnessctl;
      cliphist = lib.getExe pkgs.cliphist;
      fuzzel = lib.getExe pkgs.fuzzel;
      wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
    in
      if category == "applications" then
        application action

      else if category == "session" then
        if action == "lock" then
          lib.getExe pkgs.swaylock
        else if action == "powerMenu" then
          session.command "menu"
        else
          session.command action

      else if category == "media" then
        {
          playPause = "${playerctl} play-pause";
          next = "${playerctl} next";
          previous = "${playerctl} previous";
          restart = "${playerctl} position 0";
        }.${action}

      else if category == "audio" then
        {
          volumeUp = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%+";
          volumeDown = "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
          mute = "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          micMute = "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        }.${action}

      else if category == "display" then
        {
          brightnessUp = "${brightness} set +5%";
          brightnessDown = "${brightness} set 5%-";
        }.${action}

      else if category == "desktop" then
        {
          notifications =
            "${lib.getExe' pkgs.swaynotificationcenter "swaync-client"} -t";
          clipboard =
            "${cliphist} list | ${fuzzel} --dmenu | ${cliphist} decode | ${wlCopy}";
          displays = lib.getExe pkgs.wdisplays;
        }.${action}

      else
        throw "Niri: unsupported command ${category}.${action}";

  # Convert semantic window/workspace actions into Niri KDL actions.
  action = entry:
    let
      c = entry.category;
      a = entry.action;

      direction = prefix:
        lib.toLower (lib.removePrefix prefix a);

      workspace = prefix:
        lib.removePrefix prefix a;
    in
      if c == "windows" then
        if a == "close" then
          "close-window;"
        else if a == "fullscreen" then
          "fullscreen-window;"
        else if a == "floating" then
          "toggle-window-floating;"
        else if a == "previous" then
          "focus-window-previous;"
        else if lib.hasPrefix "focus" a then
          let dir = direction "focus";
          in
            if dir == "left" || dir == "right" then
              "focus-column-${dir};"
            else
              "focus-window-${dir};"
        else if lib.hasPrefix "move" a then
          let dir = direction "move";
          in
            if dir == "left" || dir == "right" then
              "move-column-${dir};"
            else
              "move-window-${dir};"
        else
          throw "Niri: unsupported window action ${a}"

      else if c == "workspaces" then
        if lib.hasPrefix "focus" a then
          "focus-workspace ${workspace "focus"};"
        else if lib.hasPrefix "move" a then
          "move-window-to-workspace ${workspace "move"};"
        else
          throw "Niri: unsupported workspace action ${a}"

      else if c == "screenshots" then
        if a == "full" then
          "screenshot-screen;"
        else if a == "region" then
          "screenshot;"
        else
          throw "Niri: unsupported screenshot action ${a}"

      else
        spawn (command c a);

  render = entry:
    "    ${key entry.key} { ${action entry} }";

  natural = enabled:
    if enabled then "natural-scroll" else "";

in
{
  bindings =
    lib.concatStringsSep "\n" (map render bindings);

  input = ''
    // Generated from user/preferences/input.nix.

    input {
        touchpad {
            ${natural input.touchpad.naturalScroll}
        }

        mouse {
            ${natural input.mouse.naturalScroll}
        }

        ${if input.focus.followsMouse
          then "focus-follows-mouse"
          else ""}
    }

    cursor {
        ${if input.cursor.hideWhenTyping
          then "hide-when-typing"
          else ""}
        hide-after-inactive-ms ${toString input.cursor.hideAfterInactiveMs}
    }
  '';
}
