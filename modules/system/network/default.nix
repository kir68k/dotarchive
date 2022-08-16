{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.networking;
in {
  options.ki.networking = {
    interfaces = mkOption {
      type = with types; listOf str;
      description = "List of network interfaces";
    };

    networkmanager.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable NetworkManager with default options";
    };

    wifi.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable WiFi with default options";
    };

    firewall.enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable firewall";
    };
  };

  config = let
    networkCfg =
      listToAttrs
      (map
        (n: {
          name = "${n}";
          value = { useDHCP = true; };
        })
        cfg.interfaces);
  in {
    networking.interfaces = networkCfg;
    networking.networkmanager.enable = cfg.networkmanager.enable;
    networking.wireless.enable = mkIf (cfg.wifi.enable) true;

    networking.firewall.enable = mkIf (cfg.firewall.enable) true;
  };
}
