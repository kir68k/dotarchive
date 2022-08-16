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

      packages = with pkgs; [
        phinger-cursors

        # QT
        qt5ct
        libsForQt5.qtstyleplugin-kvantum

        xdg-utils
      ] ++ (
        if (systemCfg.connectivity.sound.enable)
        then [ calibre pavucontrol pasystray ]
        else [ ]
      );

      keyboard.layout = "dk";
    };

    gtk = {
      enable = true;
      #font = {
      #  name = "";
      #  package = ;
      #};
      theme = {
        name = "Qogir-Dark";
        package = pkgs.qogir-theme;
      };
      iconTheme = {
        name = "Qogir-dark";
        package = pkgs.qogir-icon-theme;
      };
      gtk3.extraConfig = {
        gtk-cursor-theme-name = "phinger-cursors";
        gtk-application-prefer-dark-theme = true;
      };
    };

    xdg = {
      systemDirs.data = [
        "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}"
      ];

      configFile = {
        "qt5ct/qt5ct.conf" = {
          text = ''
            [Appearance]
            icon_theme=Qogir-dark
            style=kvantum_dark
          '';
        };

        "Kvantum/kvantum.kvconfig" = {
          text = ''
            theme=Qogir-Kvantum-Dark
          '';
        };

        "Kvantum/Qogir-Kvantum-Dark" = {
          source = "${pkgs.qogir-kde}/share/Kvantum/Qogir-dark";
        };

        "wallpapers" = {
          source = ./wallpapers;
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
          source = "${pkgs.phinger-cursors}/share/icons/phinger-cursors";
        };

        "icons/Qogir-dark" = {
          source = "${pkgs.qogir-icon-theme}/share/icons/Qogir-dark";
        };

        "icons/gnome" = {
          source = "${pkgs.gnome-icon-theme}/share/icons/gnome";
        };

        "icons/hicolor" = {
          source = "${pkgs.hicolor-icon-theme}/share/icons/hicolor";
        };
      };
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        icon-theme = "Qogir-dark";
        cursor-theme = "phinger-cursors";
        text-scaling-factor = 1.25;
      };
    };

    xdg = {
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
    };
  };
}
