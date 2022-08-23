{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.rrStack;
  mainDir = "/rrStack";
  liDirSetup = with pkgs;
    writeShellScriptBin "liDirSetup" ''
      liDir="${mainDir}/lidarr"
      if [ ! -e ${mainDir} ]; then
        mkdir ${mainDir} && chown -R root:rrStack ${mainDir}
        chmod -R 774 ${mainDir}
      fi

      if [ ! -e $liDir ]; then
        mkdir $liDir && chown -R lidarr:rrStack $liDir
      fi
    '';
  soDirSetup = with pkgs;
    writeShellScriptBin "soDirSetup" ''
      ${substituteInPlace} ${liDirSetup}/bin/liDirSetup --replace "lidarr" "sonarr" \
        --replace "liDir" "soDir"
    '';
  raDirSetup = with pkgs;
    writeShellScriptBin "raDirSetup" ''
      ${substituteInPlace} ${liDirSetup}/bin/liDirSetup --replace "lidarr" "radarr" \
        --replace "liDir" "raDir"
    '';
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
        default = "${mainDir}/radarr";
        description = "Data file directory";
      };
    };

    sonarr = {
      enable = mkEnableOption "Enable Sonarr";
      dataDir = mkOption {
        type = types.str;
        default = "${mainDir}/sonarr";
        description = "Data file directory";
      };
    };

    lidarr = {
      enable = mkEnableOption "Enable Lidarr";
      dataDir = mkOption {
        type = types.str;
        default = "${mainDir}/lidarr";
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

    users = {
      users = {
        radarr = mkIf (cfg.radarr.enable) {
          name = "radarr";
          group = "radarr";
          extraGroups = ["rrStack"];
        };

        sonarr = mkIf (cfg.sonarr.enable) {
          name = "sonarr";
          group = "sonarr";
          extraGroups = ["rrStack"];
        };

        lidarr = mkIf (cfg.lidarr.enable) {
          name = "lidarr";
          group = "lidarr";
          extraGroups = ["rrStack"];
        };
      };
      groups = {
        rrStack = {
          members = ["radarr" "sonarr" "lidarr"];
        };
      };
    };

    # Home directory has 700 perms, can't put dirs in e.g ~/Lidarr...
    # TODO maybe change the way this works?
    # TODO make this more fugging efficient you fat
    systemd.services = {
      radarr = mkIf (cfg.radarr.enable) {
        serviceConfig = {
          ExecStartPre = "${raDirSetup}/bin/raDirSetup";
          PermissionsStartOnly = true;
        };
      };

      sonarr = mkIf (cfg.sonarr.enable) {
        serviceConfig = {
          ExecStartPre = "${soDirSetup}/bin/soDirSetup";
          PermissionsStartOnly = true;
        };
      };

      lidarr = mkIf (cfg.lidarr.enable) {
        serviceConfig = {
          ExecStartPre = "${liDirSetup}/bin/liDirSetup";
          PermissionsStartOnly = true;
        };
      };
    };
  };
}
