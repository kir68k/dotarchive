{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.tty;
in {
  options.ki.tty = {
    enable = mkEnableOption "Set extra options for the Linux TTY, leaving this to false doesn't disable the TTY itself ;w;";

    enableEarly = mkOption {
      type = types.bool;
      default = false;
      description = "Enable said options as early as possible, in the initrd stage";
    };

    font = {
      path = mkOption {
        type = types.path;
        default = "${pkgs.terminus_font}/share/consolefonts/ter-u20n.psf.gz";
        description = "Path of font for the TTY";
      };

      pkg = mkOption {
        type = types.package;
        default = "terminus_font";
        description = "Package for the font, if required";
      };
    };

    kbdLayout = mkOption {
      type = types.str;
      default = "dk";
      description = "Keyboard layout, look at /nix/store/[...]-kbd-[ver]/share/keymaps/i386/qwerty for a list";
    };
  };

  config = mkIf (cfg.enable) {
    console = {
      earlySetup = cfg.enableEarly;
      keyMap = "${cfg.kbdLayout}";
      font = "${builtins.toString cfg.font.path}";
      packages = with pkgs; [ cfg.font.pkg ];
    };
  };
}
