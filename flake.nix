# PURPOSE: Pin and compose the infrastructure's reproducible dependencies.
# flake-parts keeps host/user output declarations outside this entry point.
# CUSTOMIZATION: Select examples through infrastructure/modules/flake.
# SECURITY: Exporting and building configurations does not activate them.
{
  description = "ijs - portable Nix infrastructure";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lazyvim.url = "github:pfassina/lazyvim-nix";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.flake-parts.flakeModules.modules
        ./infrastructure/modules/flake/registry.nix
        ./infrastructure/modules/flake/public-api.nix
        ./infrastructure/modules/flake/starter.nix
        ./infrastructure/modules/flake/lazyvim-check.nix
        ./infrastructure/modules/flake/portability.nix
      ];
      systems = [ "x86_64-linux" ];
    };
}
