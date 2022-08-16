{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.applications;
in {
  options.ki.applications = {
    steam.enable = mkEnableOption "Enable steam";
  };

  config = mkIf (cfg.steam.enable == true && config.ki.graphical.enable) {
    programs.steam = {
      enable = true;
    };
  };
}
