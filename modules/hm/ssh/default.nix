{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let 
  cfg = config.ki.ssh;
in {
  options.ki.ssh = {
    enable = mkEnableOption "Enable OpenSSH";

    git = {
      enable = mkEnableOption "Enable extra config for git";

      domain = mkOption {
        type = types.str;
        default = "";
        description = "Git repository fqdn";
      };

      keyPath = mkOption {
        type = types.str;
        default = "";
        description = "SSH keyfile to use";
      };

      port = mkOption {
        type = types.port;
        default = null;
        description = "Port to connect through";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      matchBlocks = mkIf cfg.git.enable {
        "${cfg.git.domain}" = {
          hostname = "${cfg.git.domain}";
          identityFile = "${cfg.git.keyPath}";
          port = cfg.git.port;
        };
      };
    };
  };
}