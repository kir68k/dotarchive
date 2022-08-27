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
      environment.systemPackages = with pkgs; [linuxKernel.packages.linux_zen.cpupower];
      boot.kernelParams = ["mem_sleep_default=deep" "intel_pstate=passive"];
      boot.extraModprobeConfig = ''
        options i915 enable_guc=3
        options i915 enable_fbc=1
      '';
    }
    (mkIf cfg.fprint.enable {
      services.fprintd.enable = true;
    })
    (mkIf (config.ki.graphical.enable) {
      environment.defaultPackages = with pkgs; [intel-gpu-tools];
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
      environment.variables = {
        GDK_SCALE = "1.5";
        GDK_DPI_SCALE = "0.5";
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
