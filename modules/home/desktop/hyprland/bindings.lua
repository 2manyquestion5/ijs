
-- =============================================================================
-- HYPRLAND — KEYBOARD AND MOUSE BINDINGS
-- =============================================================================
--
-- Purpose:
--   Contain the final Hyprland binding configuration.
--
-- Shared user shortcuts originate from:
--   user/preferences/bindings.nix
--
-- How generation works:
--
--   1. default.nix loads this file as a text template.
--   2. The Nix binding adapter imports the user preferences.
--   3. The adapter translates semantic actions into Hyprland Lua.
--   4. Nix replaces the marker below with generated Lua commands.
--   5. Home Manager installs and loads the finished configuration.
--
-- IMPORTANT:
--   Lua does not evaluate .nix files directly.
--   The translation happens before Hyprland starts.
--
-- Rules:
--   - Shared shortcut choices belong in preferences/bindings.nix.
--   - Hyprland-specific interactions belong below.
--   - Do not duplicate shortcuts generated from shared preferences.
--
-- =============================================================================


-- =============================================================================
-- GENERATED SHARED USER BINDINGS
-- =============================================================================
--
-- The Nix adapter replaces this entire marker line with generated Lua.
--
-- Example generated output:
--
--   hl.bind("SUPER + Q", hl.dsp.window.close())
--
-- This marker is deliberately a Lua comment until the translator is wired.

-- @SHARED_BINDINGS@


-- =============================================================================
-- HYPRLAND-SPECIFIC BINDINGS
-- =============================================================================
--
-- These actions use native Hyprland behavior and are not currently
-- part of the shared user shortcut vocabulary.
--
-- If an interaction becomes portable across several desktops,
-- consider defining a semantic action in preferences/bindings.nix.


-- Drag a floating or tiled window with Super + left mouse button.
hl.bind(
  "SUPER + mouse:272",
  hl.dsp.window.drag(),
  { mouse = true }
)


-- Resize a window with Super + right mouse button.
hl.bind(
  "SUPER + mouse:273",
  hl.dsp.window.resize(),
  { mouse = true }
)


-- =============================================================================
-- FUTURE HYPRLAND-ONLY BINDINGS
-- =============================================================================
--
-- Add native compositor interactions here when they do not fit the
-- portable action vocabulary.
--
-- Possible future additions:
--   - Special workspace controls
--   - Tiling layout adjustments
--   - Grouped windows
--   - Custom window rules
--
-- Shared actions such as fullscreen, workspaces, screenshots and media
-- controls should be implemented by the binding translator instead.
--
-- NOTE:
--   The old application, workspace and session bindings must be removed
--   from the active configuration only when the shared adapter replaces
--   them successfully.
