# LazyVim editor configuration
#
# PURPOSE: Retains the working editor and applies the user-selected color theme.
# ROLE: Imported from the user’s Home Manager configuration.
# CUSTOMIZATION: Language extras are intentionally explicit; modify them only for selected profiles.

{ theme, ... }:

  {

programs.lazyvim = {
  enable = true;

  extras = {
    lang.nix.enable = true;
    lang.python.enable = true;
  };
      plugins.colorScheme = ''
    return {
      {
        "catppuccin/nvim",
        opts = {
          flavour = "${theme.catppuccinFlavor}",
          },
        },
    }
  '';
};

}
