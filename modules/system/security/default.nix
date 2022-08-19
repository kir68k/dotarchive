{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.security;
in {
  options.ki.security = {
    doas = {
      enable = mkEnableOption "Enable the Linux fork of doas, disable sudo";

      user = mkOption {
        type = with types; listOf str;
        default = [];
        description = "User doas should be enabled for with extra settings";
      };

      keepEnv = mkOption {
        type = types.bool;
        default = true;
        description = "Keep envvars of parent process in the doas environment";
      };

      persist = mkOption {
        type = types.bool;
        default = true;
        description = "Use timestamp files (like `sudo`) to not ask for password for a while after typing it once";
      };
    };
  };

  config = mkIf (cfg.doas.enable) {
    security = {
      sudo.enable = false;
      doas = {
        enable = true;
        extraRules = [
          {
            users = cfg.doas.user;
            keepEnv = cfg.doas.keepEnv;
            persist = cfg.doas.persist;
          }
        ];
      };
    };
  };
}
