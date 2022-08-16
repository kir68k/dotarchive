{
  pkgs,
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical;
  systemCfg = config.machineData.systemConfig;
in {
  config = mkIf (cfg.xorg.enable == true || cfg.wayland.enable == true) {
    home = {
      sessionVariables = {
        QT_QPA_PLATFORMTHEME = "qt5ct";
      };

      packages = with pkgs;
        [
          phinger-cursors

          # QT
          qt5ct
          libsForQt5.qtstyleplugin-kvantum

          xdg-utils
        ]
        ++ (
          if (systemCfg.connectivity.sound.enable)
          then [calibre pavucontrol pasystray]
          else []
        );

      keyboard.layout = "dk";
    };

    gtk = with pkgs; {
      enable = true;
      #font = {
      #  name = "";
      #  package = ;
      #};
      theme = {
        name = "TokyoNight";
        package = kipkgs.tokyonight-gtk;
      };
      iconTheme = {
        name = "Numix";
        package = numix-icon-theme;
      };
      gtk3.extraConfig = {
        gtk-cursor-theme-name = "phinger-cursors";
        gtk-application-prefer-dark-theme = true;
      };
    };

    xdg = with pkgs; {
      enable = true;
      mime.enable = true;
      mimeApps = {
        enable = true;
        associations.added = {
          "x-scheme-handler/terminal" = "alacritty.desktop";
          "x-scheme-handler/file" = "org.kde.dolphin.desktop";
          "x-directory/normal" = "org.kde.dolphin.desktop";
        };
        defaultApplications = {
          "application/pdf" = "okularApplication_pdf.desktop";
          "application/x-shellscript" = "nvim.desktop";
          "application/x-perl" = "nvim.desktop";
          "application/json" = "nvim.desktop";
          "text/x-readme" = "nvim.desktop";
          "text/plain" = "nvim.desktop";
          "text/markdown" = "nvim.desktop";
          "text/x-csrc" = "nvim.desktop";
          "text/x-chdr" = "nvim.desktop";
          "text/x-python" = "nvim.desktop";
          "text/x-tex" = "texstudio.desktop";
          "text/x-makefile" = "nvim.desktop";
          "inode/directory" = "org.kde.dolphin.desktop";
          "x-directory/normal" = "org.kde.dolphin.desktop";
          "x-scheme-handler/file" = "org.kde.dolphin.desktop";
          "x-scheme-handler/terminal" = "alacritty.desktop";
        };
      };
      systemDirs.data = [
        "${gtk3}/share/gsettings-schemas/${gtk3.name}"
        "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}"
      ];

      configFile = {
        "qt5ct/qt5ct.conf" = {
          text = ''
            [Appearance]
            icon_theme=Numix
            style=kvantum-dark
          '';
        };

        "Kvantum/kvantum.kvconfig" = {
          text = ''
            theme=TokyoNight
          '';
        };

        "Kvantum/TokyoNight" = {
          source = "${kipkgs.tokyonight-kvantum}/share/Kvantum/TokyoNight";
        };

        "wallpapers" = {
          source = ./wallpapers;
        };

        "kdeglobals" = {
          text = ''
            [General]
            TerminalApplication=${alacritty}/bin/alacritty
          '';
        };
      };

      dataFile = {
        "icons/default/index.theme" = {
          text = ''
            [icon theme]
            Inherits=phinger-cursors
          '';
        };

        "icons/phinger-cursors" = {
          source = "${phinger-cursors}/share/icons/phinger-cursors";
        };

        "icons/Numix" = {
          source = "${numix-icon-theme}/share/icons/Numix";
        };

        "icons/gnome" = {
          source = "${gnome-icon-theme}/share/icons/gnome";
        };

        "icons/hicolor" = {
          source = "${hicolor-icon-theme}/share/icons/hicolor";
        };
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        icon-theme = "Numix";
        cursor-theme = "phinger-cursors";
        text-scaling-factor = 1.5;
      };
    };
  };
}
