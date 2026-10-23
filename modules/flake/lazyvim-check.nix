# PURPOSE: Test the real wrapped editor and HM-generated files in clean homes.
# CONSUMER: lazyvim-offline and lazyvim-lifecycle checks; no host activation.
# CUSTOMIZATION: Keep this fixture editor-only; assertions live in tests/lazyvim-offline.lua.
# SECURITY: Temporary child environments and test-only network command guards never
# modify a real home. Negative cases must fail, including attempted plugin downloads.
{ inputs, self, ... }:
{
  perSystem = { pkgs, lib, ... }:
    let
      makeHome = extraModules: inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          self.modules.homeManager.lazyvim
          {
            home.username = "example";
            home.homeDirectory = "/home/example";
            home.stateVersion = "26.05";
          }
        ] ++ extraModules;
      };
      home = makeHome [ {
        _module.args.theme = (self.ijs.resolveTheme { inherit lib; }) "mocha-purple";
      } ];
      # Existing callers may still import the same upstream path explicitly.
      legacy = makeHome [ inputs.lazyvim.homeManagerModules.default {
        _module.args.theme = (self.ijs.resolveTheme { inherit lib; }) "mocha-purple";
      } ];
      # No theme argument: disabling must not evaluate editor-specific defaults.
      disabled = makeHome [ { programs.lazyvim.enable = false; } ];
      plain = makeHome [ {
        programs.lazyvim.enable = false;
        programs.neovim = {
          enable = true;
          initLua = "vim.g.ijs_plain_editor = true";
        };
      } ];
      editorFiles = configuration: lib.filter
        (file: file.enable && (lib.hasPrefix ".config/nvim/" file.target
          || lib.hasPrefix ".local/share/nvim/" file.target))
        (lib.attrValues configuration.config.home.file);
      alternateDirectory = makeHome [ {
        _module.args.theme = (self.ijs.resolveTheme { inherit lib; }) "mocha-purple";
        programs.lazyvim.appName = "another-editor";
      } ];
      linkFiles = name: configuration: pkgs.writeShellScript name ''
        # Test only Home Manager's own collision/link phases, not host activation.
        set -e
        ${configuration.config.lib.bash.initHomeManagerLib}
        export VERBOSE_ARG= HOME_MANAGER_BACKUP_EXT= HOME_MANAGER_BACKUP_COMMAND=
        ${configuration.config.home.activation.checkLinkTargets.data}
        ${configuration.config.home.activation.linkGeneration.data}
      '';
      guard = pkgs.writeShellScriptBin "git" ''
        for argument in "$@"; do
          case "$argument" in
            clone|fetch|pull|ls-remote)
              printf 'git %s\n' "$*" >> "$IJS_NETWORK_ATTEMPTS"
              exit 97 ;;
          esac
        done
        exec ${pkgs.git}/bin/git "$@"
      '';
      changedTemplate = builtins.tryEval (import ../home/programs/lazyvim-init.nix {
        inherit lib pkgs;
        upstreamInit = "unexpected upstream template";
      });
    in {
      checks.lazyvim-offline = assert !changedTemplate.success;
        pkgs.runCommand "ijs-lazyvim-offline" {
          nativeBuildInputs = [ pkgs.coreutils pkgs.gnugrep ];
        } ''
        # Each invocation starts without any user cache; copy only declared HM files.
        for mode in good existing missing misnamed network; do
          test_home=$(mktemp -d)
          # Keep declared symlinks, but not the store directories' read-only modes.
          # In particular, .cache/.keep must not make the test user's cache read-only.
          cp -R --no-preserve=mode ${home.config.home-files}/. "$test_home/"
          mkdir -p "$test_home/work" "$test_home/.cache" "$test_home/.local/state"
          attempts="$test_home/network-attempts"
          if [ "$mode" = existing ]; then
            mkdir -p "$test_home/.config/nvim" "$test_home/.local/share/nvim/lazy"
            printf 'keep user configuration\n' > "$test_home/.config/nvim/user-note.txt"
            printf 'keep user state\n' > "$test_home/.local/share/nvim/user-state.txt"
            # Old installations may have this bootstrap symlink; never delete it.
            ln -s ${pkgs.vimPlugins.lazy-nvim} "$test_home/.local/share/nvim/lazy/lazy.nvim"
          fi
          status=0
          env --chdir="$test_home/work" HOME="$test_home" XDG_CONFIG_HOME="$test_home/.config" \
            XDG_DATA_HOME="$test_home/.local/share" XDG_STATE_HOME="$test_home/.local/state" \
            XDG_CACHE_HOME="$test_home/.cache" XDG_CONFIG_DIRS= XDG_DATA_DIRS= \
            IJS_TEST_MODE="$mode" IJS_NETWORK_ATTEMPTS="$attempts" IJS_GIT_GUARD="${guard}/bin" \
            timeout --kill-after=5s 60s ${home.config.programs.neovim.finalPackage}/bin/nvim \
              --headless --cmd 'lua vim.env.PATH = vim.env.IJS_GIT_GUARD .. ":" .. vim.env.PATH' \
              '+luafile ${../../tests/lazyvim-offline.lua}' \
              > "$test_home/output" 2>&1 || status=$?
          cat "$test_home/output"
          if [ "$mode" = good ] || [ "$mode" = existing ]; then
            test "$status" = 0
            test ! -s "$attempts"
          else
            test "$status" = 1
            grep -F "IJS_REGRESSION: $mode" "$test_home/output"
          fi
        done
        touch "$out"
      '';

      checks.lazyvim-lifecycle =
        # The pinned legacy file phases respect the disposable HOME below.
        assert lib.all (c: c.config.home.fileActivator == "legacy") [ home disabled plain ];
        assert editorFiles disabled == [ ];
        assert !disabled.config.programs.neovim.enable;
        assert plain.config.programs.neovim.plugins == [ ];
        assert plain.config.programs.lazyvim.plugins == { };
        assert legacy.config.xdg.configFile."nvim/init.lua".text
          == home.config.xdg.configFile."nvim/init.lua".text;
        assert !(builtins.tryEval
          (toString alternateDirectory.config.xdg.configFile."nvim/init.lua".source)).success;
        pkgs.runCommand "ijs-lazyvim-lifecycle" {
          nativeBuildInputs = [ pkgs.bash pkgs.coreutils pkgs.findutils pkgs.diffutils pkgs.gettext pkgs.gnugrep ];
        } ''
          test_home=$(mktemp -d -t ijs-lazyvim-lifecycle.XXXXXX)
          env HOME="$test_home" IJS_TEST_HOME="$test_home" \
            XDG_CONFIG_HOME="$test_home/.config" XDG_DATA_HOME="$test_home/.local/share" \
            XDG_STATE_HOME="$test_home/.local/state" XDG_CACHE_HOME="$test_home/.cache" \
            bash ${../../tests/lazyvim-lifecycle.sh} \
              ${home.activationPackage} ${disabled.activationPackage} ${plain.activationPackage} \
              ${linkFiles "link-lazyvim" home} ${linkFiles "link-disabled" disabled} ${linkFiles "link-plain" plain} \
              ${plain.config.programs.neovim.finalPackage}/bin/nvim
          touch "$out"
        '';
    };
}
