{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.git;
in {
  options.ki.git = {
    enable = mkEnableOption "Enable Git VCS";

    userName = mkOption {
      type = types.str;
      default = "Lapic";
      description = "Username for Git";
    };

    userMail = mkOption {
      type = types.str;
      default = "lapic@kirinsst.xyz";
      description = "Email for Git user";
    };
  };

  config = mkIf (cfg.enable) {
    programs.git = {
      enable = true;
      userName = cfg.userName;
      userEmail = cfg.userMail;
      extraConfig = {
        init.defaultBranch = "stream";
        pull.rebase = "true";
        merge.conflictstyle = "zdiff3";
      };
    };

    home.packages = with pkgs; [
      scripts.devTools
    ];
  };
}
