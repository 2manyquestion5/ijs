# PURPOSE: Boot the example and verify integrated Home Manager and user tools.
# CONSUMER: checks.x86_64-linux.portability-vm, using the same modules as the launchable VM.
# CUSTOMIZATION: Add runtime checks only for behavior this small example promises.
# SECURITY: The NixOS test harness controls only its disposable guest, not a real workstation.
{ pkgs, vmModules }:
let
  # Test-only guard, matching the editor check: expose any attempted Git installer.
  gitGuard = pkgs.writeShellScriptBin "git" ''
    for argument in "$@"; do
      case "$argument" in
        clone|fetch|pull|ls-remote)
          printf 'git %s\n' "$*" >> "$IJS_NETWORK_ATTEMPTS"
          exit 97 ;;
      esac
    done
    exec ${pkgs.git}/bin/git "$@"
  '';
in
pkgs.testers.runNixOSTest {
  name = "ijs-home-portability";
  nodes.machine.imports = vmModules;

  testScript = ''
    import shlex

    machine.start()
    machine.wait_for_unit("multi-user.target")
    try:
        machine.wait_for_unit("home-manager-example.service")
    except Exception:
        # A failed oneshot has a useful nonzero status; log it without asserting success.
        for command in [
            "systemctl --no-pager --full status home-manager-example.service",
            "journalctl --boot --no-pager -u home-manager-example.service",
            "journalctl --boot --no-pager -u nix-daemon.service -u register-nix-paths.service",
        ]:
            status, output = machine.execute(command + " 2>&1")
            machine.log(f"{command} (exit {status})\n{output}")
        raise
    machine.wait_for_unit("register-nix-paths.service")
    machine.succeed("test -L /home/example/.config/tmux/tmux.conf")
    machine.succeed("test -L /home/example/.config/nvim/init.lua")

    def as_example(command):
        return machine.succeed("runuser -l example -c " + shlex.quote(command))

    # Exercise the daemon as the same unprivileged user that Home Manager uses.
    as_example("nix-store --query --requisites /run/current-system > /dev/null")
    for command in ["git --version", "tmux -V", "rg --version", "fd --version"]:
        as_example(command)
    # Reuse the application's regression assertions against this VM user's editor.
    # The actual wrapper prepends Git to PATH, so restore the guard before init.lua.
    editor_state = as_example("mktemp -d -t ijs-editor-check.XXXXXX").strip()
    as_example(
        "IJS_TEST_MODE=good "
        "IJS_NETWORK_ATTEMPTS=" + shlex.quote(editor_state + "/network-attempts") + " "
        "IJS_GIT_GUARD=${gitGuard}/bin "
        "timeout --kill-after=5s 60s nvim --headless "
        "--cmd 'lua vim.env.PATH = vim.env.IJS_GIT_GUARD .. \":\" .. vim.env.PATH' "
        "'+luafile ${./lazyvim-offline.lua}'"
    )
    as_example("test ! -s " + shlex.quote(editor_state + "/network-attempts"))
    assert "copy-selection-and-cancel" in as_example(
        "cat ~/.config/tmux/tmux.conf"
    )
    assert "wheel" not in as_example("id -nG").split()
    machine.fail("systemctl is-active display-manager.service")
    machine.fail("systemctl is-active sshd.service")
  '';
}
