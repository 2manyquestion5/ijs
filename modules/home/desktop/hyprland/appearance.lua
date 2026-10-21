-- Hyprland visual and layout settings
--
-- PURPOSE: Contains compositor-specific appearance that cannot be expressed as shared keybindings.
-- ROLE: Loaded by the Hyprland session alongside translated user preferences.
-- CUSTOMIZATION: Preserve currently working Hyprland Lua API calls and test after updates.

hl.config({
  general = {
    gaps_in = 2,
    gaps_out = 4,
    border_size = 1,
    resize_on_border = true,
  },

  cursor = {
    hide_on_key_press = true,
    inactive_timeout = 3,
  },

  decoration = {
    rounding = 3,

    active_opacity = 0.98,
    inactive_opacity = 0.94,

    shadow = {
      enabled = true,
      range = 8,
      render_power = 2,
      color = "rgba(00000055)",
    },

    blur = {
      enabled = true,
      size = 4,
      passes = 2,
    },
  },

  animations = {
    enabled = true,
  },
})
