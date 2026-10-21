# PURPOSE:
# Register the standard ijs Home Manager example.
#
# SECURITY:
# This is a buildable configuration example.
# It does not create an operating-system account or change any host.
#
# PORTABILITY:
# The example uses the public ijs modules and preference functions.
# Real installations supply their own account and host configuration.

{ inputs, self, ... }:

let
  system = "x86_64-linux";

in {
  flake.homeConfigurations.example =
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${system};

      extraSpecialArgs = {
        ijs = self;
      };

      modules = [
        inputs.lazyvim.homeManagerModules.default

        ../../configurations/users/default
      ];
    };
}
