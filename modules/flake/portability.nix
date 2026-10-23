# PURPOSE: Compose the same user module through standalone and integrated Home Manager.
# CONSUMERS: Public examples and focused checks, independent of personal configurations.
# CUSTOMIZATION: Edit examples/portability for tools or guest policy; no profile engine is used.
# SECURITY: Building outputs never activates them on the host. The VM is not an installer.
{ inputs, self, lib, ... }:
let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  userModules = [
    ../../examples/portability/home.nix
  ];
  standalone = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs.ijs = self;
    modules = userModules ++ [ {
      home.username = "example";
      home.homeDirectory = "/home/example";
    } ];
  };
  vmModules = [
    inputs.home-manager.nixosModules.home-manager
    ../../examples/portability/vm.nix
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs.ijs = self;
        sharedModules = userModules;
        # Home Manager gets this account's name and home from NixOS.
        users.example = { };
      };
    }
  ];
in
{
  # flake-parts treats unknown outputs as unique values. Declare a normal
  # attribute set so this example and starter.nix can each contribute a home.
  options.flake.homeConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
    description = "Standalone Home Manager configurations.";
  };

  config = {
    flake.homeConfigurations.portability = standalone;
    flake.nixosConfigurations.development-vm = inputs.nixpkgs.lib.nixosSystem {
      inherit system;
      modules = vmModules;
    };

    perSystem = { pkgs, ... }: {
      checks = {
        tmux-clipboard = pkgs.runCommand "ijs-tmux-clipboard" {
          nativeBuildInputs = [ pkgs.tmux pkgs.bash pkgs.coreutils pkgs.gnugrep ];
          LC_ALL = "en_US.UTF-8";
          LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
          waylandConfig = pkgs.writeText "tmux-wayland.conf"
            self.homeConfigurations.example.config.xdg.configFile."tmux/tmux.conf".text;
          terminalConfig = pkgs.writeText "tmux-terminal.conf"
            standalone.config.xdg.configFile."tmux/tmux.conf".text;
        } ''
          export SHELL=${pkgs.runtimeShell}
          bash ${../../tests/tmux-clipboard.sh} "$waylandConfig" "$terminalConfig"
          touch "$out"
        '';
        portability-vm = import ../../tests/portability.nix { inherit pkgs vmModules; };
      };
    };
  };
}
