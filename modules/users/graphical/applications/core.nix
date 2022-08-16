{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical;
in {
  options.ki.graphical.applications = {
    enable = mkEnableOption "Enable graphical applications";
  };

  config = mkIf (cfg.applications.enable) {
    home.packages = with pkgs; [
      geogebra
      dolphin
      okular
      wdisplays

      thunderbird
      flameshot
      libsixel

      element-desktop
    ];
  };
}
