{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.tor;
in {
  options.ki.tor = {
    enable = mkEnableOption "Enable and configure Tor";

    relay = {
      enable = mkEnableOption "Enable a fully configured Tor relay";
      name = mkOption {
        type = types.str;
        default = config.networking.hostName; # TODO disable this? Just how private can a hostname be :|
        description = "Name of your Tor relay, defaults to your hostname";
      };
    };
    client = {
      enable = mkEnableOption "Enable Tor as a client, used for e.g proxying programs through tor";
      transProxy = mkOption {
        type = types.bool;
        default = false;
        description = "Enable transparent proxy support for Tor";
      };
      bridges = {
        enable = mkOption {
          type = types.bool;
          default = false;
          description = "Use an unlisted Tor bridge relay while connecting";
        };
        brAttrs = mkOption {
          type = types.lines;
          default = builtins.toString null;
          description = "Once you know your bridges, paste their protocol, IP, fingerprint and extra attrs here";
        };
      };
    };
  };

  config = let
    torSettings = mkMerge [
      (mkIf (cfg.relay.enable) {
        services.tor = {
          enable = true;
          relay = {
            enable = true;
            role = "relay";
          };
          settings = {
            ORPort = 9001;
            Nickname = cfg.relay.name;
            Sandbox = true;
            DirPort = 9030;
            DNSPort = "auto";
            ContactInfo = builtins.toString null; # TODO set this >.>
          };
        };
      })
      (mkIf (cfg.client.enable) {
        services.tor = {
          enable = true;
          client = {
            enable = true;
            dns.enable = true;
            transparentProxy.enable = cfg.client.transProxy;
          };
          # I can't find a fuging way to add bridge attributes here
          # services.tor.extraConfig was removed so bruh
          settings = mkIf (cfg.client.useBridges) {
            UseBridges = "1";
            ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
          };
        };
      })
    ];
  in
    torSettings;
}
