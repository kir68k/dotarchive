{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:
with lib; let
  cfg = config.ki.git;
in {
  options.ki.git = {
    enable = mkEnableOption "Enable Git VCS";

    userName = mkOption {
      type = types.str;
      default = "";
      description = "Username for e.g. Git commits";
    };

    userMail = mkOption {
      type = types.str;
      default = "";
      description = "Email for Git user";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userMail;
      extraConfig = {
        init.defaultBranch = "stream";
        pull.rebase = true;
        merge.conflictstyle = "zdiff3";
      };
    };
  };
}