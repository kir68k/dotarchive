{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical.xorg;
in {
  options.ki.graphical.xorg = {
    enable = mkEnableOption "Enable X11";
  };

  config = mkIf (config.ki.graphical.enable && cfg.enable) {
    services.xserver = {
      enable = true;
      libinput = {
        enable = true;
        mouse = {
          accelProfile = "adaptive";
          accelSpeed = "1";
        };
        touchpad = {
          naturalScrolling = true;
        };
      };

      displayManager.startx.enable = true;
    };
  };
}
