# PURPOSE: Test the real wrapped editor and HM-generated files in clean homes.
# CONSUMER: checks.x86_64-linux.lazyvim-offline; no host activation is performed.
# CUSTOMIZATION: Keep this fixture editor-only; assertions live in tests/lazyvim-offline.lua.
# SECURITY: Temporary child environments and test-only network command guards never
# modify a real home. Negative cases must fail, including attempted plugin downloads.
{ inputs, self, ... }:
{
  perSystem = { pkgs, lib, ... }:
    let
      home = inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          inputs.lazyvim.homeManagerModules.default
          self.modules.homeManager.lazyvim
          {
            _module.args.theme = (self.ijs.resolveTheme { inherit lib; }) "mocha-purple";
            home.username = "example";
            home.homeDirectory = "/home/example";
            home.stateVersion = "26.05";
          }
        ];
      };
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
        for mode in good missing misnamed network; do
          test_home=$(mktemp -d)
          cp -R ${home.config.home-files}/. "$test_home/"
          mkdir -p "$test_home/work" "$test_home/.cache" "$test_home/.local/state"
          attempts="$test_home/network-attempts"
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
          if [ "$mode" = good ]; then
            test "$status" = 0
            test ! -s "$attempts"
          else
            test "$status" = 1
            grep -F "IJS_REGRESSION: $mode" "$test_home/output"
          fi
        done
        touch "$out"
      '';
    };
}
