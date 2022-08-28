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
      torDir="${mainDir}/torrents"
      if [ ! -e ${mainDir} ]; then
        mkdir ${mainDir} && chown -R root:rrStack ${mainDir}
        chmod -R 774 ${mainDir}
      fi

      if [ ! -e $liDir ]; then
        mkdir $liDir && chown -R lidarr:rrStack $liDir
      fi
      if [ ! -e $torDir ]; then
        mkdir $torDir && mkdir -p $torDir/{complete,incomplete}
        chown -R transmission:rrStack $torDir
      fi
      if [ ! -e /home/ki/Music/Lidarr]; then
        ln -s $liDir/rootDir /home/ki/Music/Lidarr
      fi
    '';
  jackDirSetup = with pkgs;
    writeShellScriptBin "jackDirSetup" ''
      jackDir="${mainDir}/jackett"
      if [ ! -e $jackDir ]; then
        mkdir $jackDir && chown -R jackett:rrStack $jackDir
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
      package = pkgs.lidarr;
      dataDir = mkOption {
        type = types.str;
        default = "${mainDir}/lidarr";
        description = "Data file directory";
      };
    };

    jackett = {
      enable = mkEnableOption "Enable Jackett, don't use Prowlarr with this.";
      package = pkgs.jackett;
      dataDir = mkOption {
        type = types.str;
        default = "${mainDir}/jackett";
        description = "Data file directory";
      };
    };

    prowlarr = {
      enable = mkEnableOption "Enable Prowlarr, don't use Jackett with this.";
    };
  };

  config = mkIf (cfg.enable) {
    # IPFS sets this to something else, needs mkForce or else Nix can't override IPFS' existing value
    boot.kernel.sysctl = mkIf (config.ki.ipfs.enable) {
      "net.core.rmem_max" = mkForce "8388608";
    };
    services = {
      transmission = {
        enable = true;
        openPeerPorts = true;
        settings = {
          download-dir = "/rrStack/torrents/complete";
          incomplete-dir = "/rrStack/torrents/incomplete";
        };
      };

      jackett = mkIf (cfg.jackett.enable) {
        enable = true;
        dataDir = cfg.jackett.dataDir;
        openFirewall = cfg.common.openFirewall;
      };

      prowlarr = mkIf (cfg.prowlarr.enable) {
        enable = true;
        openFirewall = cfg.common.openFirewall;
      };

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
        transmission = {
          name = "transmission";
          group = "transmission";
          extraGroups = ["rrStack"];
        };

        jackett = {
          name = "jackett";
          group = "jackett";
          extraGroups = ["rrStack" "transmission"];
          isSystemUser = true;
        };

        prowlarr = {
          name = "prowlarr";
          group = "prowlarr";
          extraGroups = ["rrStack" "transmission"];
          isSystemUser = true;
        };

        radarr = mkIf (cfg.radarr.enable) {
          name = "radarr";
          group = "radarr";
          extraGroups = ["rrStack" "transmission"];
        };

        sonarr = mkIf (cfg.sonarr.enable) {
          name = "sonarr";
          group = "sonarr";
          extraGroups = ["rrStack" "transmission"];
        };

        lidarr = mkIf (cfg.lidarr.enable) {
          name = "lidarr";
          group = "lidarr";
          extraGroups = ["rrStack" "transmission"];
        };
      };
      groups = {
        rrStack = {
          members = ["prowlarr" "jackett" "radarr" "sonarr" "lidarr" "transmission"];
        };
        transmission = {
          members = ["prowlarr" "jackett" "radarr" "sonarr" "lidarr"];
        };
      };
    };

    # Home directory has 700 perms, can't put dirs in e.g ~/Lidarr...
    systemd.services = {
      jackett = mkIf (cfg.jackett.enable) {
        serviceConfig = {
          ExecStartPre = "${jackDirSetup}/bin/jackDirSetup";
          PermissionsStartOnly = true;
        };
      };

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
