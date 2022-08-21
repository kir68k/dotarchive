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
      # Work
      geogebra # Broken on Wayland, STILL >.>
      cinnamon.nemo
      xarchiver

      # Production
      # natron # broken rn
      blender
      openshot-qt
      darktable
      rawtherapee
      ffmpeg
      imagemagick
      ardour
      sage

      # Utilities
      okular
      wdisplays
      thunderbird
      flameshot
      libsixel
      kipkgs.nerdfetch # Requires a NerdFont, those don't work on a TTY (assuming, but i can bet on it), so putting it here

      # Matrix client
      element-desktop

      # Audio
      kipkgs.spotify-deb
    ];
  };
}
