
# =============================================================================
# USER PREFERENCES — INPUT BEHAVIOR
# =============================================================================
#
# Purpose:
#   Define how mouse, touchpad, keyboard focus and cursor should behave,
#   independently of the chosen desktop environment.
#
# Architecture:
#   This file defines desired behavior, not native compositor syntax.
#
#   preferences/input.nix
#            |
#            v
#      Desktop adapter
#            |
#        +---+---+
#        |       |
#     Hyprland  Niri
#        |       |
#       Lua     KDL
#
# Native settings are generated during Nix evaluation.
#
# Rules:
#   - Universal preferences belong here.
#   - Compositor-specific gestures and behavior remain in native files.
#   - Unsupported options must be reported by the adapter.
#   - Do not duplicate these values in native desktop configuration.
#
# Related files:
#   desktop/hyprland/input.lua
#   desktop/niri/input.kdl
#
# =============================================================================

{
  # ---------------------------------------------------------------------------
  # TOUCHPAD
  # ---------------------------------------------------------------------------
  # Natural scrolling:
  #   Moving two fingers upward moves the page upward, as on a phone.

  touchpad = {
    naturalScroll = true;
  };

  # ---------------------------------------------------------------------------
  # MOUSE
  # ---------------------------------------------------------------------------
  # Natural scrolling reverses the conventional mouse-wheel direction.
  #
  # Mouse and touchpad settings remain separate so they can be changed
  # independently.

  mouse = {
    naturalScroll = true;
  };

  # ---------------------------------------------------------------------------
  # KEYBOARD FOCUS
  # ---------------------------------------------------------------------------
  # Keyboard focus determines which window receives typed text.
  #
  # followsMouse = false:
  #   Moving the pointer over another window does not automatically
  #   transfer keyboard focus.
  #
  # scrollUnfocusedWindows = true:
  #   Scroll the window underneath the pointer without changing
  #   the currently focused keyboard window.
  #
  # Note:
  #   Compositors implement focus and pointer behavior differently.
  #   Adapters must preserve the intended behavior where supported.

  focus = {
    followsMouse = false;
    scrollUnfocusedWindows = true;
  };

  # ---------------------------------------------------------------------------
  # CURSOR VISIBILITY
  # ---------------------------------------------------------------------------
  # Hide the pointer while typing.
  #
  # Also hide the pointer after 3000 milliseconds (3 seconds) without
  # pointer activity.
  #
  # Moving the pointer should reveal it again.
  #
  # Note:
  #   Timeout semantics can differ between compositors.

  cursor = {
    hideWhenTyping = true;
    hideAfterInactiveMs = 3000;
  };
}
