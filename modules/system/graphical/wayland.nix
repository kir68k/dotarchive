{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical.wayland;
in {
  options.ki.graphical.wayland = {
    enable = mkEnableOption "Enable Wayland";

    swaylock-pam = mkOption {
      type = types.bool;
      default = false;
      description = "Enable PAM integration for swaylock";
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [xwayland];
    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
    };

    security.pam.services.swaylock = mkIf (cfg.swaylock-pam) {};
  };
}
