# PURPOSE: Pin and compose the infrastructure's reproducible dependencies.
# flake-parts keeps host/user output declarations outside this entry point.
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
        ./modules/flake/registry.nix
        ./modules/flake/public-api.nix
        ./modules/flake/starter.nix
        ./modules/flake/lazyvim-check.nix
      ];
      systems = [ "x86_64-linux" ];
    };
}
