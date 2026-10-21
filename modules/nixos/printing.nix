# =============================================================================
# Printing
# =============================================================================
#
# Printing is disabled by default.
#
# Enable this capability when a printer is configured and needed.
# Network printer discovery should be reviewed separately.
#
# =============================================================================

{ ... }:

{
  services.printing.enable = false;
}
