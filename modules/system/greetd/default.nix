{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.greetd;
in {
  options.ki.greetd.enable = mkEnableOption "Enable greetd";

  config = mkIf (cfg.enable) {
    services.greetd = {
      enable = true;
      restart = true;
      settings = {
        terminal.vt = 1;
        default_session = let
          swaySession = pkgs.writeTextFile {
            name = "sway-session.desktop";
            destination = "/sway-session.desktop";
            text = ''
              [Desktop Entry]
              Name=Sway
              Exec=$HOME/.winitrc
            '';
          };

          zshSession = pkgs.writeTextFile {
            name = "zsh-session.desktop";
            destination = "/zsh-session.desktop";
            text = ''
              [Desktop Entry]
              Name=Terminal
              Exec=${pkgs.zsh}/bin/zsh
            '';
          };

          xorgSession = pkgs.writeTextFile {
            name = "xorg-session.desktop";
            destination = "/xorg-session.desktop";
            text = ''
              [Desktop Entry]
              Name=X11
              Exec=${pkgs.xorg.xinit}/bin/startx
            '';
          };

          sessionDirs = builtins.concatStringsSep ":" (
            [zshSession] ++ (
              if (config.ki.graphical.enable && config.ki.graphical.wayland.enable)
              then [swaySession]
              else []
            ) ++ (
              if (config.ki.graphical.enable && config.ki.graphical.xorg.enable)
              then [xorgSession]
              else []
            )
          );
        in {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --sessions ${sessionDirs} --remember --remember-session";
          user = "greeter";
        };
      };
    };
  };
}
