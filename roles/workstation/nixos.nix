# PURPOSE: A desktop role; includes supported desktop services.
# Host selects this explicitly; user controls personal settings separately.
{ ... }: { imports = [
  ../../modules/nixos/hyprland.nix
  ../../modules/nixos/niri.nix
  ../../modules/nixos/gnome.nix
  ../../features/input/nixos.nix
]; }
