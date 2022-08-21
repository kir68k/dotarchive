{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.rrStack;
in {
  options.ki.rrStack = {
    enable = mkEnableOption "Enable configuration for rr-programs";

    # Common settings for all rr-programs
    common = {
      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open ports in the firewall";
      };
    };

    radarr = {
      enable = mkEnableOption "Enable Radarr";
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/radarr/.config/Radarr";
        description = "Data file directory";
      };
    };

    sonarr = {
      enable = mkEnableOption "Enable Sonarr";
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/sonarr/.config/Radarr";
        description = "Data file directory";
      };
    };

    lidarr = {
      enable = mkEnableOption "Enable Lidarr";
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/lidarr/.config/Radarr";
        description = "Data file directory";
      };
    };
  };

  config = mkIf (cfg.enable) {
    services = {
      radarr = mkIf (cfg.radarr.enable) {
        enable = true;
        dataDir = cfg.radarr.dataDir;
        openFirewall = cfg.common.openFirewall;
      };

      sonarr = mkIf (cfg.sonarr.enable) {
        enable = true;
        dataDir = cfg.sonarr.dataDir;
        openFirewall = cfg.common.openFirewall;
      };

      lidarr = mkIf (cfg.lidarr.enable) {
        enable = true;
        dataDir = cfg.lidarr.dataDir;
        openFirewall = cfg.common.openFirewall;
      };
    };
  };
}
