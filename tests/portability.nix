# PURPOSE: Boot the example and verify integrated Home Manager and user tools.
# CONSUMER: checks.x86_64-linux.portability-vm, using the same modules as the launchable VM.
# CUSTOMIZATION: Add runtime checks only for behavior this small example promises.
# SECURITY: The NixOS test harness controls only its disposable guest, not a real workstation.
{ pkgs, vmModules }:
pkgs.testers.runNixOSTest {
  name = "ijs-home-portability";
  nodes.machine.imports = vmModules;

  testScript = ''
    import shlex

    machine.start()
    machine.wait_for_unit("multi-user.target")
    machine.wait_for_unit("home-manager-example.service")
    machine.succeed("test -L /home/example/.config/tmux/tmux.conf")
    machine.succeed("test -L /home/example/.config/nvim/init.lua")

    def as_example(command):
        return machine.succeed("runuser -l example -c " + shlex.quote(command))

    for command in ["git --version", "tmux -V", "rg --version", "fd --version"]:
        as_example(command)
    as_example("nvim --headless '+lua assert(vim.fn.exists(\":Lazy\") == 2)' +qa")
    assert "copy-selection-and-cancel" in as_example(
        "cat ~/.config/tmux/tmux.conf"
    )
    assert "wheel" not in as_example("id -nG").split()
    machine.fail("systemctl is-active display-manager.service")
    machine.fail("systemctl is-active sshd.service")
  '';
}
