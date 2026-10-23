# PURPOSE: Pure, explainable compatibility matching before provisioning.
# IMPORTANT: host capabilities are DECLARED claims, not runtime attestation.
# A host owner must authorize the selected session; no guest privilege grant.
{ lib }: { request, host }:
let
  acceptable = request.allowedModes or [ "native" "vm" "terminal" ];
  modes = lib.filter (mode: builtins.elem mode (host.supportedModes or [])) acceptable;
  requiredRam = request.minMemoryMiB or 0;
  ramAvailable = host.freeMemoryMiB or 0;
  nonfreeForbidden = request.forbidNonfreeHost or false;
  nonfreePresent = host.requiresNonfree or false;
  reasons =
    (lib.optional (modes == []) "no-supported-session-mode") ++
    (lib.optional (requiredRam > ramAvailable) "insufficient-memory") ++
    (lib.optional (nonfreeForbidden && nonfreePresent) "nonfree-host-incompatible");
in {
  compatible = reasons == [];
  inherit reasons;
  selectedMode = if reasons == [] then builtins.head modes else null;
}
