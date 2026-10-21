# Hyprland preference adapter
#
# PURPOSE: Converts normalized portable bindings and input into native Hyprland Lua.
# ROLE: Loaded by the translator; should not import dev’s files directly.
# CUSTOMIZATION: Maintain support for the version-specific Lua API.

# =============================================================================
# HYPRLAND ADAPTER
# =============================================================================
#
# Translates portable user preferences into Hyprland Lua.
#
# This module does NOT load preferences from disk.
# The central translator passes them in.
#
# Adding another desktop must not require changing this file.
#
# Output:
#   {
#     bindings = "...Lua...";
#     input = "...Lua...";
#   }
#
# =============================================================================

{ lib, pkgs, preferences, translate }:

let
  bindings = translate.validateBindings preferences.bindings;
  input = preferences.input;
  apps = preferences.applications;

  session = import ../../actions/session.nix { inherit lib pkgs; };

  # Produce a Lua boolean literal.
  bool = value: if value then "true" else "false";

  # Format our portable key names for Hyprland.
  key = value:
    lib.concatStringsSep " + " (
      map (part:
        {
          LEFT = "left";
          RIGHT = "right";
          UP = "up";
          DOWN = "down";
          ESCAPE = "Escape";
          SPACE = "Space";
          TAB = "Tab";
          PRINT = "Print";
        }.${part} or part
      ) (lib.splitString "+" value)
    );

  # Wrap a shell command using Hyprland's exec dispatcher.
  exec = command:
    "hl.dsp.exec_cmd(${builtins.toJSON command})";

  # Return a native executable path for a selected application.
  application = name:
    let app = apps.${name};
    in lib.getExe' app.package app.executable;

  # Shell commands shared conceptually with other desktops.
  # Native window actions are handled separately below.
  command = category: action:
    let
      wpctl = lib.getExe' pkgs.wireplumber "wpctl";
      playerctl = lib.getExe pkgs.playerctl;
      brightness = lib.getExe pkgs.brightnessctl;
      grim = lib.getExe pkgs.grim;
      slurp = lib.getExe pkgs.slurp;
      cliphist = lib.getExe pkgs.cliphist;
      fuzzel = lib.getExe pkgs.fuzzel;
      wlCopy = lib.getExe' pkgs.wl-clipboard "wl-copy";
      screenshots = ''"$HOME/Pictures/Screenshots"'';
      filename = ''$(date +%Y-%m-%d_%H-%M-%S).png'';
    in
      if category == "applications" then
        application action

      else if category == "session" then
        if action == "lock" then
          lib.getExe pkgs.hyprlock
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

      else if category == "screenshots" then
        {
          full =
            "mkdir -p ${screenshots} && ${grim} ${screenshots}/${filename}";
          region =
            ''mkdir -p ${screenshots} && ${grim} -g "$(${slurp})" ${screenshots}/${filename}'';
        }.${action}

      else
        throw "Hyprland: unsupported command ${category}.${action}";

  # Convert a semantic action into a native Hyprland Lua dispatcher.
  action = entry:
    let
      c = entry.category;
      a = entry.action;

      direction =
        prefix:
          lib.toLower (lib.removePrefix prefix a);

      workspace =
        prefix:
          lib.removePrefix prefix a;
    in
      if c == "windows" then
        if a == "close" then
          "hl.dsp.window.close()"
        else if a == "fullscreen" then
          "hl.dsp.window.fullscreen({ action = \"toggle\" })"
        else if a == "floating" then
          "hl.dsp.window.float({ action = \"toggle\" })"
        else if a == "previous" then
          "hl.dsp.focus({ last = true })"
        else if lib.hasPrefix "focus" a then
          "hl.dsp.focus({ direction = ${builtins.toJSON (direction "focus")} })"
        else if lib.hasPrefix "move" a then
          "hl.dsp.window.swap({ direction = ${builtins.toJSON (direction "move")} })"
        else
          throw "Hyprland: unsupported window action ${a}"

      else if c == "workspaces" then
        if lib.hasPrefix "focus" a then
          "hl.dsp.focus({ workspace = ${workspace "focus"} })"
        else if lib.hasPrefix "move" a then
          "hl.dsp.window.move({ workspace = ${workspace "move"} })"
        else
          throw "Hyprland: unsupported workspace action ${a}"

      else
        exec (command c a);

  # Translate every shared shortcut.
  render = entry:
    "hl.bind(${builtins.toJSON (key entry.key)}, ${action entry})";

  focusMode =
    if input.focus.followsMouse then 1
    else if input.focus.scrollUnfocusedWindows then 2
    else 0;

in
{
  bindings =
    lib.concatStringsSep "\n" (map render bindings);

  input = ''
    -- Generated from user/preferences/input.nix.

    hl.config({
      input = {
        follow_mouse = ${toString focusMode},
        natural_scroll = ${bool input.mouse.naturalScroll},

        touchpad = {
          natural_scroll = ${bool input.touchpad.naturalScroll},
        },
      },

      cursor = {
        hide_on_key_press = ${bool input.cursor.hideWhenTyping},
        inactive_timeout =
          ${toString (input.cursor.hideAfterInactiveMs / 1000.0)},
      },
    })
  '';
}
