{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.relativity;
in {
  options.ki.relativity = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable T480-specific options";
    };

    fprint.enable = mkEnableOption "Enable fingerprint scanner";
  };

  config = mkIf (cfg.enable) (mkMerge [
    {
      boot.kernelParams = [ "mem_sleep_default=deep" ];
      boot.extraModprobeConfig = ''
        options i915 enable_guc=3
        options i915 enable_fbc=1
      '';
    }
    (mkIf cfg.fprint.enable {
      services.fprintd.enable = true;
    })
    (mkIf (config.ki.graphical.enable) {
      environment.defaultPackages = with pkgs; [ intel-gpu-tools ];
      hardware = {
        video.hidpi.enable = true;
        opengl = {
          enable = true;
          extraPackages = with pkgs; [
            intel-media-driver
            vaapiIntel
            vaapiVdpau
            libvdpau-va-gl
          ];
        };
      };
      services.xserver.dpi = 180;
      # TODO should this be here does this work what another 3 AM todo ffs
      environment.variables = {
        GDK_SCALE = "1.5";
        GDK_DPI_SCALE = "0.5";
        _JAVA_OPTIONS = "-Dsun.java2d.uiScale=1.5";
      };

      services.xserver.displayManager.sessionCommands = ''
        ${pkgs.xorg.xrdb}/bin/xrdb -merge <<EOF
          Xcursor.size: 42
          Xft.autohint: 0
          Xft.lcdfilter: lcddefault
          Xft.hintstyle: hintfull
          Xft.hinting: 1
          Xft.antialias: 1
          Xft.rgba: rgb
        EOF
      '';
    })
  ]);
}
