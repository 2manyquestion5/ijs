# Audio system capability
#
# PURPOSE: Provides PipeWire audio and session support for desktop hosts.
# ROLE: Selected by a host role; do not activate merely because this module exists.
# CUSTOMIZATION: Review if converting a machine into a headless server.

{ ... }:

{
  # Enable sound with PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # If you want to use JACK applications, uncomment this.
    # jack.enable = true;
  };
}
