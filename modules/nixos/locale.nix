# System locale and timezone
#
# PURPOSE: Defines machine-wide regional defaults independently of a user’s portable preferences.
# ROLE: NixOS host module, not a user account setting.
# CUSTOMIZATION: Adapt timezone and locale for other host locations.

{ ... }:

{

  # time zone
  time.timeZone = "Europe/Amsterdam";

  # International properties
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {

  LC_ADDRESS = "nl_NL.UTF-8";
  LC_IDENTIFICATION = "nl_NL.UTF-8";
  LC_MEASUREMENT = "nl_NL.UTF-8";
  LC_MONETARY = "nl_NL.UTF-8";
  LC_NAME = "nl_NL.UTF-8";
  LC_NUMERIC = "nl_NL.UTF-8";
  C_PAPER = "nl_NL.UTF-8";
  LC_TELEPHONE = "nl_NL.UTF-8";
  LC_TIME = "nl_NL.UTF-8";

  };

}
