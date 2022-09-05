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
        default = config.networking.hostName;
        description = "Name of your Tor relay, defaults to your hostname, but it is recommended to set it to whatever other value.";
      };

      contact = mkOption {
        type = types.str;
        default = "";
        description = "Contact info that will get listed on your relay's page (metrics.torproject.org), a recommended setting would be your email address.";
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
            ContactInfo = cfg.relay.contact;
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
          settings = mkIf (cfg.client.bridges.enable) {
            UseBridges = "1";
            ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/obfs4proxy";
            # Idek if these work, I just HAD to set *something* here or else Tor wouldn't start
            "bridge" = [
              "obfs4 45.32.196.110:7246 035CC684A22F0C1C28FD3CAC981AABBEEF000E28 cert=JqzUffDFJS0QY5iObd3ajV3Qj4SOkTjHYGVIg9r7IApDIgH76UlpntuneY83rSR2x3Nnfw iat-mode=0"
              "obfs4 46.226.106.214:63202 1CFD0D96B8AE6E98B0FD21374E55FA17ABBC44F1 cert=rEik+Qgmtr7O2q4p9QeEwJq5RUNuZl40J2twN/ZLiUY3zvRciA2uGGjz5jTOXPM+vF8INQ iat-mode=0"
              "obfs4 104.194.235.58:60965 B35D736AB8124EF08626EE4F25A03B0720FA07C8 cert=/YP6d+x5KXmCkHipSnn9cprh5OVzKdT3pUxYgzpm17bD+ZfQBXOJbmPzq32RTyMdOF7bNw iat-mode=0"
            ];
          };
        };
      })
    ];
  in
    torSettings;
}
