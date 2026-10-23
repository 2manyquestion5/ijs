# PURPOSE: Reusable theme data; user preferences select this by name.
# No Home Manager module is imported simply to choose a theme.
let palette = import ./palette.nix; in {
  name = "mocha-purple";
  catppuccinFlavor = "mocha";
  accent = palette.mauve;
  accentAlt = palette.lavender;
  healthy = palette.teal;
  warning = palette.peach;
  critical = palette.red;
  inherit palette;
}
