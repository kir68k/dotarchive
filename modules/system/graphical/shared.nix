{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical;
in {
  options.ki.graphical = {
    enable = mkEnableOption "Enable graphics";
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      # Graphics
      libva-utils
      vdpauinfo
      glxinfo
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
    ];

    fonts.fonts = with pkgs; [
      (nerdfonts.override {fonts = ["FiraCode" "Iosevka" "DroidSansMono"];})
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      cantarell-fonts
      liberation_ttf
      lato
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      font-awesome
      ubuntu_font_family
      terminus_font
      ibm-plex
      roboto
      roboto-slab
      roboto-mono
    ];

    hardware.opengl = {
      enable = true;
      extraPackages = [
        pkgs.mesa.drivers
      ];
    };

    environment.etc."profile.local".text = builtins.concatStringsSep "\n" ([
        ''
          # /etc/profile.local: Generated automatically, DO NOT EDIT.
          if [ -f "$HOME/.profile" ]; then
            . "$HOME/.profile"
          fi
        ''
      ]
      ++ (
        if (cfg.xorg.enable && !config.ki.greetd.enable)
        then [
          ''
            if [ -z "$DISPLAY" ] && ["''${XDG_VTNR}" -eq 1 ]; then
              exec startx
            fi
          ''
        ]
        else []
      )
      ++ (
        if (cfg.wayland.enable && !config.ki.greetd.enable)
        then [
          ''
            if [ -z "$DISPLAY" ] && [ "''${XDG_VTNR}" -eq 2 ]; then
              exec $HOME/.winitrc
            fi
          ''
        ]
        else []
      ));
  };
}
