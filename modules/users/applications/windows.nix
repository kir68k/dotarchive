{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.applications.win64;
in {
  options.ki.applications.win64 = {
    enable = mkEnableOption "Enable Wine and Mono";

    staging = mkEnableOption "Use staging package intead of stable";
  };

  config = mkIf (cfg.enable) {
    home.packages = with pkgs; [
      (
        if (cfg.staging)
        then wineWowPackages.staging
        else if (config.ki.graphical.wayland.enable)
        then wineWowPackages.waylandFull
        else wineWowPackages.stable
      )
      winetricks
      mono
    ];
  };
}
