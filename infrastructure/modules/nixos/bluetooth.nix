# Bluetooth capability
#
# PURPOSE:
#   Provides optional Bluetooth support for headphones and peripherals.
#
# WHY IT EXISTS:
#   Bluetooth belongs to a host capability, not a portable user's
#   personal application list.
#
# SECURITY:
#   Bluetooth support is available, but the controller starts off.
#   Users can power it on when needed.
#
# USED BY:
#   Hosts that explicitly import this module.

{ ... }:

{
  # Enable the Bluetooth stack.
  hardware.bluetooth.enable = true;

  # Start with the radio powered off.
  hardware.bluetooth.powerOnBoot = false;

  # Enable the Bluetooth management service.
  services.blueman.enable = true;
}
