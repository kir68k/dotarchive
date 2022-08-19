{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.direnv;
in {
  options.ki.direnv = {
    enable = mkEnableOption "Enable direnv";
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
