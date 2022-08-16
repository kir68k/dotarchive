{
  config,
  pkgs,
  lib,
  ...
}:

with lib; {
  config.ki.graphical = {
    wayland = {
      enable = mkDefault false;
      type = mkDefault null;

      swaybg = {
        enable = mkDefault false;
        image = mkDefault ./wallpapers/bg2.png;
        mode = mkDefault "fill";
        pkg = mkDefault pkgs.swaybg;
      };

      fehbg = {
        enable = mkDefault false;
        image = mkDefault ./wallpapers/bg2.png;
        mode = mkDefault "fill";
        pkg = mkDefault pkgs.feh;
      };

      bar = {
        enable = mkDefault false;
        pkg = mkDefault pkgs.waybar;
      };

      lock.enable = mkDefault false;
    };
  };
}
