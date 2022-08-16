{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical.xorg;
  systemCfg = config.machineData.systemConfig;
in {
  options.ki.graphical.xorg = {
    enable = mkEnableOption "Enable X11 for HM user";

    type = mkOption {
      type = types.enum [ "xmonad" ];
      default = null;
      description = "Which DE/WM to use, currently only `xmonad`";
    };
  };

  config = mkIf (cfg.enable) {
    assertions = [
      {
        assertion = systemCfg.graphical.xorg.enable;
        message = "X11 must be enabled on the `system` in order to be enabled for the `user`";
      }
    ];

    home.packages = with pkgs; [
      xmobar
    ];

    xsession.windowManager.xmonad = (mkIf (cfg.type == "xmonad") {
      enable = true;
      enableContribAndExtras = true;
      haskellPackages = with pkgs; [ # Necessary? TODO
        haskellPackages.dbus
        haskellPackages.List
        haskellPackages.monad-logger
        haskellPackages.xmonad-contrib
        haskellPackages.xmonad-extras
      ];
      config = ./xmonad/xmonad.hs;
    });
  };
}
