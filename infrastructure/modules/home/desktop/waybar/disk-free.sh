#!/usr/bin/env bash

# Waybar root-disk availability
#
# PURPOSE: Displays available space for the root filesystem.
# ROLE: A Waybar custom module invokes this script.
# CUSTOMIZATION: Update the mount target if the widget should track a different disk.

df -BG / | awk 'NR==2 {
  gsub("G", "", $4)
  print $4 "G"
}'
