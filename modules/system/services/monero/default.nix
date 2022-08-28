{
  config,
  pkgs,
  lib,
  ...
}:
with builtins;
with lib; let
  cfg = config.ki.monerod;
in {
  options.ki.monerod = {
    enable = mkEnableOption "Enable the monero daemon";

    dataDir = mkOption {
      type = types.str;
      default = "/zrx/monero";
      description = "Directory for monerod's data, blockchain DB will be in it's own directory one level down from this.";
    };

    rpc = {
      enable = mkEnableOption "Whether to enable RPC for the node";

      restricted = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to restrict the RPC in pursuit of security, !! RECOMMENDED IF RUNNING A PUBLIC NODE !!";
      };

      public = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to make this a publicly accessible node, useful if you want to e.g. use your node from your phone over LTE instead of your WLAN";
      };

      port = mkOption {
        type = types.port;
        default = 18081;
        description = "Port for the RPC to listen on";
      };

      ip4addr = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "IPv4 address the RPC should listen on";
      };

      ip6addr = mkOption {
        type = types.str;
        default = "";
        description = "IPv6 address for the RPC to listen on, NOT TESTED YET. THE CONFIG DOESN'T UNDERSTAND THE COMPRESSION DOUBLE COLON, WRITE WHOLE ADDR";
      };
    };

    p2p = {
      port = mkOption {
        type = types.port;
        default = 18080;
        description = "Port for the P2P node to listen on";
      };

      ip4addr = mkOption {
        type = types.str;
        default = "0.0.0.0";
        description = "IPv4 address for the P2P node to listen on";
      };

      ip6 = {
        enable = mkEnableOption "Enable IPv6 support";
        addr = mkOption {
          type = types.str;
          default = "";
          description = "IPv6 address for the P2P node to listen on. NOT TESTED YET. THE CONFIG DOESN'T UNDERSTAND THE COMPRESSION DOUBLE COLON, WRITE WHOLE ADDR";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    services.monero = {
      enable = true;
      dataDir = cfg.dataDir;
      limits = {
        threads = 4;
        download = 1048576;
        upload = 1048576;
        syncSize = 0;
      };

      rpc = mkIf cfg.rpc.enable {
        restricted = cfg.rpc.restricted;
        port = cfg.rpc.port;
        address = cfg.port.address;
      };

      # builtins.toString on booleans returns "1" or "", not "true" or "false"... Would be nice if it could return "0" instead of "".
      extraConfig = ''
        p2p-bind-ip=${cfg.p2p.ip4addr}
        p2p-bind-port=${toString cfg.p2p.port}

        p2p-use-ipv6=${
          if cfg.p2p.ip6.enable
          then "true"
          else "false"
        }
        p2p-bind-ipv6-address=${cfg.p2p.ip6.addr}

        log-level=2
        rpc-ssl=autodetect
        public-node=${
          if cfg.rpc.public
          then "true"
          else "false"
        }
        confirm-external-bind=${
          if cfg.rpc.public
          then "1"
          else "0"
        }

        max-txpool-weight=268435456

        prune-blockchain=false
        db-sync-mode=safe
        enforce-dns-checkpointing=true
        enable-dns-blocklist=true
        no-igd=true
        no-zmq=true

        out-peers=96
        in-peers=96

        disable-rpc-ban=1

        check-updates=disabled
      '';
    };
  };
}
