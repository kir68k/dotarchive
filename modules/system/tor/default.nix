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
              "obfs4 163.172.189.163:80 CB228CB122E3013FC1057FCD2006E8553E25F1CC cert=I3wBfenslUHKObVuLN5JfEUe4rwBAG3cU8mmdwdGd4yXTpwUvGcRg13nZeCZR4G9us6ALw iat-mode=0"
              "obfs4 23.234.193.87:32490 EBB4057F2490347EF9D7ABB5FCD715C06369721E cert=3oRwMDuyUCbpKeAQfmQgZevXU6Fn2D3NXP3OZK2itsCi8iHcfTKQvJ3zL1l1BoSTEmduew iat-mode=0"
              "obfs4 142.47.223.227:8443 38866E175AE605CE22CBE44B6656E27360AF5340 cert=jIGl6AX6qSq0C7WoqBOP3kY7Tlere8r3SRQ+noCP/PiT7yToLcVYe9RlCkwrBKyptMG/Fg iat-mode=0"
            ];
          };
        };
      })
    ];
  in
    torSettings;
}
