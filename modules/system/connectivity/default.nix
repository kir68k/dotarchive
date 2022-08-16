{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.connectivity;
in {
  options.ki.connectivity = {
    bluetooth.enable = mkEnableOption "Enable bluetooth configured";

    firewall.enable = mkEnableOption "Enable firewall";

    printing.enable = mkEnableOption "Enable printing support";

    sound.enable = mkEnableOption "Enable sound";
  };

  config = {
    environment.systemPackages = with pkgs;
      [ ] ++ (
        if (cfg.sound.enable)
        then [ pulseaudio scripts.soundTools ]
        else [ ]
      );

    security.rtkit.enable = cfg.sound.enable;
    services.pipewire = mkIf cfg.sound.enable {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    services.printing.enable = cfg.printing.enable;

    hardware.bluetooth.enable = cfg.bluetooth.enable;
    services.blueman.enable = cfg.bluetooth.enable;
  };
}
