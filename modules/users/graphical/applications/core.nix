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
      (
        zotero.overrideAttrs
        (_: rec {
          version = "6.0.13";
          src = pkgs.fetchurl {
            url = "https://download.zotero.org/client/release/${version}/Zotero-${version}_linux-x86_64.tar.bz2";
            sha512 = "FQrT8hOtcongn3lCL0hApKKI2Av+ZhqcBtMwGYxSAY7+AbxoYpSF/YImR5At9Z7FhivuXfE9HeEGoszYS2R5RA==";
          };
        })
      )
      qnotero

      # Production
      # natron # broken rn
      blender
      openshot-qt
      darktable
      rawtherapee
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
