
# =============================================================================
# USER PREFERENCES — KEYBOARD SHORTCUTS
# =============================================================================
#
# Purpose:
#   Define which keys perform which actions, independently of the desktop.
#
# Architecture:
#   1. This file defines semantic actions and their preferred shortcuts.
#   2. A desktop adapter reads these preferences using Nix.
#   3. The adapter translates each action into native compositor commands.
#   4. Home Manager installs the generated configuration.
#
# For example:
#
#   windows.close = "SUPER+Q";
#
# Becomes, depending on the desktop:
#
#   Hyprland: hl.bind("SUPER + Q", hl.dsp.window.close())
#   Niri:     Mod+Q { close-window; }
#
# Rules:
#   - Define keyboard preferences here, not in desktop-specific files.
#   - Use semantic action names rather than compositor commands.
#   - Keep shared shortcut syntax consistent (SUPER+SHIFT+KEY).
#   - Native adapters must explicitly support each requested action.
#   - Duplicate shortcuts should be rejected during validation.
#
# Related files:
#   applications.nix              Which applications are launched
#   input.nix                     Mouse, touchpad, focus and cursor behavior
#   desktop/hyprland/bindings.lua Hyprland-specific bindings
#   desktop/niri/bindings.kdl     Niri-specific bindings
#
# =============================================================================

{
  # ---------------------------------------------------------------------------
  # APPLICATIONS
  # ---------------------------------------------------------------------------
  # Program selection belongs in applications.nix.
  # These entries only specify the shortcuts used to launch them.

  applications = {
    apps      = "SUPER+A";          # Application launcher
    terminal  = "SUPER+T";          # Terminal emulator
    browser   = "SUPER+B";          # Web browser
    files     = "SUPER+D";          # File manager (Dolphin)
    wifi      = "SUPER+C";          # Network connections
    bluetooth = "SUPER+SHIFT+C";    # Bluetooth manager
  };

  # ---------------------------------------------------------------------------
  # WINDOW MANAGEMENT
  # ---------------------------------------------------------------------------
  # The same action can have a different native implementation.
  #
  # Example:
  #   moveLeft:
  #     Hyprland swaps with the neighboring tiled window.
  #     Niri moves the active column to the left.
  #
  # Fullscreen is distinct from maximization and floating.

  windows = {
    close      = "SUPER+Q";
    fullscreen = "SUPER+F";
    floating   = "SUPER+W";

    # Cycle back to the previously focused window.
    previous = "SUPER+TAB";

    # Keyboard focus
    focusLeft  = "SUPER+LEFT";
    focusRight = "SUPER+RIGHT";
    focusUp    = "SUPER+UP";
    focusDown  = "SUPER+DOWN";

    # Rearrange windows or columns
    moveLeft  = "SUPER+SHIFT+LEFT";
    moveRight = "SUPER+SHIFT+RIGHT";
    moveUp    = "SUPER+SHIFT+UP";
    moveDown  = "SUPER+SHIFT+DOWN";
  };

  # ---------------------------------------------------------------------------
  # WORKSPACES
  # ---------------------------------------------------------------------------
  # Five workspaces initially.
  #
  # Future:
  #   Consider generating workspace shortcuts from a configurable count.
  #   Additional workspaces should not require changing adapter logic.

  workspaces = {
    focus1 = "SUPER+1";
    focus2 = "SUPER+2";
    focus3 = "SUPER+3";
    focus4 = "SUPER+4";
    focus5 = "SUPER+5";

    move1 = "SUPER+SHIFT+1";
    move2 = "SUPER+SHIFT+2";
    move3 = "SUPER+SHIFT+3";
    move4 = "SUPER+SHIFT+4";
    move5 = "SUPER+SHIFT+5";
  };

  # ---------------------------------------------------------------------------
  # SESSION MANAGEMENT
  # ---------------------------------------------------------------------------
  # These shortcuts request actions, not shell commands.
  #
  # Logout and shutdown must use session-aware implementations.
  # Destructive actions should require confirmation.
  #
  # On shared machines, system policy may restrict shutdown.

  session = {
    logout    = "SUPER+SHIFT+Q";
    shutdown  = "SUPER+SHIFT+ESCAPE";
    lock      = "SUPER+L";
    powerMenu = "SUPER+ESCAPE";
  };

  # ---------------------------------------------------------------------------
  # DESKTOP UTILITIES
  # ---------------------------------------------------------------------------

  desktop = {
    notifications = "SUPER+N";
    clipboard     = "SUPER+V";
    displays      = "SUPER+P";
  };

  # ---------------------------------------------------------------------------
  # MEDIA PLAYBACK
  # ---------------------------------------------------------------------------
  # Intended to control the active MPRIS-compatible media player.
  #
  # The implementation may use playerctl or another media controller.
  #
  # restart:
  #   Seek to the beginning of the current track.
  #   Some players do not support seeking.

  media = {
    playPause = "SUPER+SPACE";
    next      = "SUPER+S";
    previous  = "SUPER+SHIFT+SPACE";
    restart   = "SUPER+R";
  };

  # ---------------------------------------------------------------------------
  # AUDIO
  # ---------------------------------------------------------------------------
  # Uses dedicated hardware keys.
  #
  # Volume changes are currently intended to use 5% increments.
  # The adjustment amount belongs in a future audio preference module.

  audio = {
    volumeUp   = "XF86AudioRaiseVolume";
    volumeDown = "XF86AudioLowerVolume";
    mute       = "XF86AudioMute";
    micMute    = "XF86AudioMicMute";
  };

  # ---------------------------------------------------------------------------
  # DISPLAY BRIGHTNESS
  # ---------------------------------------------------------------------------

  display = {
    brightnessUp   = "XF86MonBrightnessUp";
    brightnessDown = "XF86MonBrightnessDown";
  };

  # ---------------------------------------------------------------------------
  # SCREENSHOTS
  # ---------------------------------------------------------------------------
  # Screenshot tools may differ between desktops.
  #
  # The adapter is responsible for selecting a supported screenshot command.

  screenshots = {
    full   = "SUPER+PRINT";
    region = "PRINT";
  };
}
