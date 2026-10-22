# Waybar Home Manager integration
#
# PURPOSE: Installs Waybar configuration and the shared session control command.
# ROLE: Uses the selected theme and replaces legacy session launcher strings.
# CUSTOMIZATION: Change bar behavior in config.jsonc and appearance in style.css.
# SECURITY: User configuration does not grant host or network privileges.

{ lib, pkgs, theme, ... }:

let
  # Import the shared session-action package.
  session = import ../../../../lib/actions/session.nix {
    inherit lib pkgs;
  };

  # The source JSONC stays readable.
  # Both old power-button references become the shared command.
  config = lib.replaceStrings
    [ "portable-session menu" "~/.config/hypr/powermenu.sh" ]
    [ "${session.executable} menu" "${session.executable} menu" ]
    (builtins.readFile ./config.jsonc);

in
{
  # Make portable-session available to the user's shell.
  home.packages = [ session.package ];

  # Install the generated Waybar configuration.
xdg.configFile."waybar/config.jsonc".text = config;
xdg.configFile."waybar/style.css".source = ./style.css;

xdg.configFile."waybar/disk-free.sh" = {
  source = ./disk-free.sh;
  executable = true;
};

xdg.configFile."waybar/theme.css".text = ''
  @define-color base ${theme.palette.base};
  @define-color mantle ${theme.palette.mantle};
  @define-color crust ${theme.palette.crust};

  @define-color text ${theme.palette.text};
  @define-color subtext ${theme.palette.subtext0};

  @define-color surface0 ${theme.palette.surface0};
  @define-color surface1 ${theme.palette.surface1};

  @define-color accent ${theme.accent};
  @define-color accent_alt ${theme.accentAlt};

  @define-color healthy ${theme.healthy};
  @define-color warning ${theme.warning};
  @define-color critical ${theme.critical};
'';

}
