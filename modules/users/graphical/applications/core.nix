{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical;
in {
  options.ki.graphical.applications = {
    enable = mkEnableOption "Enable graphical applications";
  };

  config = mkIf (cfg.applications.enable) {
    home.packages = with pkgs; [
      geogebra # Broken on Wayland, STILL >.>
      cinnamon.nemo

      # Utilities
      okular
      wdisplays
      thunderbird
      flameshot
      libsixel

      element-desktop
      kipkgs.nerdfetch # Requires a NerdFont, those don't work on a TTY (assuming, but i can bet on it), so putting it here
    ];
  };
}
