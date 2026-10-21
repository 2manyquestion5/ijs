-- Hyprland startup actions
--
-- PURPOSE: Starts panel and notifications for the Hyprland session.
-- ROLE: Keeps startup logic separate from shortcut and input translation.
-- CUSTOMIZATION: Avoid starting the same background service from multiple desktop modules.

hl.on("hyprland.start", function ()
  hl.exec_cmd("waybar")
  hl.exec_cmd("swaync")
end)
