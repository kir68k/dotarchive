{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.applications.tmux;
in {
  options.ki.applications.tmux = {
    enable = mkEnableOption "Enable a configured tmux";

    keyMode = mkOption {
      type = types.enum ["vi" "emacs"];
      default = "vi";
      description = "Key mode, can be Vi or Emacs style";
    };
  };

  config = mkIf (cfg.enable) {
    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = cfg.keyMode;
      secureSocket = true;
      shell = "${pkgs.zsh}/bin/zsh";
    };
  };
}
