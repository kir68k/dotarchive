{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.ipfs;
in {
  options.ki.ipfs = {
    enable = mkEnableOption "Enable IPFS and a client for it";

    autoGC = mkOption {
      type = types.bool;
      default = true;
      description = "Enable automatic garbage collection";
    };

    autoMount = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically mount `/ipfs` and `/ipns` on boot";
    };
  };

  config = mkIf (cfg.enable) {
    services.ipfs = {
      enable = true;
      enableGC = cfg.autoGC;
      emptyRepo = true;
      autoMount = cfg.autoMount;
      extraConfig = {
        Datastore = {
          StorageMax = "150GB";
        };
        # Allow for Web UI access
        API = {
          HTTPHeaders = {
            Access-Control-Allow-Origin = [
              "http://localhost:3000"
              "http://127.0.0.1:5001"
              "https://webui.ipfs.io"
            ];
          };
        };
      };
    };
  };
}
