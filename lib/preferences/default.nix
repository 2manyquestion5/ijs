# PURPOSE: Materialize one user's preferences using the selected pkgs set.
# No module is allowed to choose a global dev user implicitly.
{ pkgs, directory }: {
  bindings = import (directory + "/bindings.nix");
  input = import (directory + "/input.nix");
  applications = import (directory + "/applications.nix") { inherit pkgs; };
  appearance = import (directory + "/appearance.nix");
}
