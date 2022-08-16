{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.gnome;
in {
  options.ki.gnome = {
    enable = mkEnableOption "Enable GNOME programs";

    keyring = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gnome-keyring";
      };

      gui.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable seahorse (gnome-keyring gui)";
      };
    };
  };
  
  config = mkIf (cfg.enable) {
    programs.dconf.enable = true;

    environment.systemPackages = with pkgs; mkIf (cfg.keyring.enable) [
      libsecret
    ];

    programs.seahorse.enable = cfg.keyring.enable && cfg.keyring.gui.enable;

    services.gnome = {
      gnome-keyring.enable = cfg.keyring.enable;
      at-spi2-core.enable = true;
    };
  };
}
