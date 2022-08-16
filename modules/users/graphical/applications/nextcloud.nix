{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical.applications;
in {
  options.ki.graphical.applications.nextcloud = {
    enable = mkEnableOption "Enable nextcloud";
  };

  config = mkIf (cfg.nextcloud.enable) {
    home.packages = with pkgs; [
      nextcloud-client
    ];
  };
}
