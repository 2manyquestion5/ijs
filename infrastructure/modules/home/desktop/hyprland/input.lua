
-- =============================================================================
-- HYPRLAND — INPUT AND GESTURES
-- =============================================================================
--
-- Purpose:
--   Apply shared user input preferences and define Hyprland-specific
--   input behavior.
--
-- Shared input preferences originate from:
--   user/preferences/input.nix
--
-- How generation works:
--
--   1. default.nix reads this Lua file as a text template.
--   2. The Nix input adapter loads preferences/input.nix.
--   3. It translates supported options into Hyprland Lua.
--   4. The generated Lua replaces the marker below.
--   5. Home Manager installs the completed file.
--
-- Important:
--   Natural scrolling, pointer hiding and focus preferences are
--   controlled by the shared user preference file.
--
--   Do not redefine them manually below.
--
-- =============================================================================


-- =============================================================================
-- GENERATED SHARED INPUT SETTINGS
-- =============================================================================
--
-- Expected preferences include:
--
--   - Natural touchpad scrolling
--   - Natural mouse scrolling
--   - No focus change when moving the pointer
--   - Scrolling a window without changing keyboard focus
--   - Hide cursor when typing
--   - Hide cursor after 3000 ms
--
-- The adapter must verify the corresponding options against our
-- installed Hyprland version and its Lua configuration API.

-- @SHARED_INPUT@


-- =============================================================================
-- HYPRLAND-SPECIFIC GESTURES
-- =============================================================================
--
-- The following behavior belongs to Hyprland rather than the shared
-- input preference file.
--
-- Three-finger horizontal swipe:
--   Switch between workspaces.

hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})


-- =============================================================================
-- HYPRLAND-SPECIFIC WORKSPACE BEHAVIOR
-- =============================================================================
--
-- This rule makes workspace 3 the preferred/default workspace.
--
-- It is not an input preference.
-- Eventually it could move to appearance.lua or a layout module.

hl.workspace_rule({
  workspace = "3",
  default = true,
})


-- =============================================================================
-- FUTURE HYPRLAND INPUT SETTINGS
-- =============================================================================
--
-- Add compositor-specific options here when needed.
--
-- Examples:
--   - Gesture sensitivity
--   - Touchpad gesture mappings
--   - Device-specific overrides
--   - Keyboard layout details specific to Hyprland
--
-- Prefer shared user preferences when equivalent behavior should follow
-- the user across desktops.
