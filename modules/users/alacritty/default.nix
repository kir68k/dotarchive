{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.alacritty;
in {
  options.ki.alacritty = {
    enable = mkEnableOption "Enable Alacritty terminal with a config";
  };

  config = mkIf (cfg.enable) {
    programs.alacritty = {
      enable = true;
      settings = {
        colors = {
          # BG/FG colours
          primary = {
            background = "0x1A1B26";
            foreground = "0xC0CAF5";
          };

          # Colors the cursor will follow
          cursor = {
            text = "0x1A1B26";
            cursor = "0xCFC9C2";
          };

          # Color scheme
          normal = {
            black = "0x414868";
            red = "0xF7768E";
            green = "0x9ECE6A";
            yellow = "0xE0AF68";
            blue = "0x7AA2F7";
            magenta = "0xBB9AF7";
            cyan = "0x7DCFFF";
            white = "0xC0CAF5";
          };
        };

        font = {
          normal = {
            family = "IBM Plex Mono";
            style = "Regular";
          };
          bold = {
            family = "IBM Plex Mono";
            style = "Bold";
          };
          italic = {
            family = "IBM Plex Mono";
            style = "Italic";
          };
          bold_italic = {
            family = "IBM Plex Mono";
            style = "Bold Italic";
          };
          size = 12;
        };

        window = {
          opacity = 0.85;
        };

        cursor = {
          style = {
            shape = "Block";
            blinking = "Always";
          };
          blink_interval = 500;
        };
      };
    };
  };
}
