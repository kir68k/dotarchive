{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical.wayland;
  systemCfg = config.machineData.systemConfig;

  dwlKi = pkgs.dwlBuilder {
    config.cmds = {
      term = ["${pkgs.alacritty}/bin/alacritty --config-file=/home/ki/.config/alacritty/alacritty.yml"];
      menu = ["${pkgs.bemenu}/bin/bemenu-run"];
      audioUp = ["${pkgs.scripts.soundTools}/bin/stools" "vol" "up" "5"];
      audioDown = ["${pkgs.scripts.soundTools}/bin/stools" "vol" "down" "5"];
      audioMute = ["${pkgs.scripts.soundTools}/bin/stools" "vol" "toggle"];
    };
  };
  dwlStartup = pkgs.writeShellScriptBin "dwl-setup" ''
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      eval $(dbus-launch --exit-with-session --sh-syntax)
    fi

    ## https://bbs.archlinux.org/viewtopic.php?id=224652
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd WAYLAND_DISPLAY DISPLAY XDG_CURRENT_DESKTOP
    fi

    systemctl --user import-environment PATH XDG_RUNTIME_DIR WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
    systemctl --user start dwl-session.target
  '';

  swayStartup = pkgs.writeShellScriptBin "sway-setup" ''
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      eval $(dbus-launch --exit-with-session --sh-syntax)
    fi

    ## https://bbs.archlinux.org/viewtopic.php?id=224652
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd --all
    fi

    systemctl --user restart xdg-desktop-portal-gtk.service
    systemctl --user start sway-session.target
  '';
  swayConfig = ''
    exec ${swayStartup}/bin/sway-setup

    # Super key
    set $mod Mod4

    # Directions
    set $left h
    set $right l
    set $up k
    set $down j

    set $term ${pkgs.alacritty}/bin/alacritty --config-file=/home/ki/.config/alacritty/alacritty.yml
    set $menu ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="BEMENU_SCALE=2 ${pkgs.bemenu}/bin/bemenu -i -l 8 --scrollbar autohide" --term="$term" --no-generic | xargs swaymsg exec --

    bindsym $mod+Return exec $term
    bindsym $mod+q kill
    bindsym $mod+space exec '$menu'
    bindsym $mod+Shift+q exec swaynag -t warning -m 'Do you really want to quit?' -B 'Yes' 'swaymsg exit'

    bindsym $mod+$left focus left
    bindsym $mod+$right focus right
    bindsym $mod+$up focus up
    bindsym $mod+$down focus down

    bindsym $mod+v splitv
    bindsym $mod+b splith

    bindsym $mod+a focus parent

    bindsym $mod+Shift+$left move left
    bindsym $mod+Shift+$right move right
    bindsym $mod+Shift+$up move up
    bindsym $mod+Shift+$down move down

    bindsym $mod+Control+$right resize shrink width 10px
    bindsym $mod+Control+$left resize grow width 10px
    bindsym $mod+Control+$up resize shrink height 10px
    bindsym $mod+Control+$down resize grow height 10px

    bindsym $mod+f+space fullscreen toggle
    bindsym $mod+s layout stacking
    bindsym $mod+Shift+f fullscreen disable, floating disable, layout default
    bindsym $mod+t layout tabbed
    bindsym $mod+Shift+s layout toggle

    bindsym $mod+Shift+space floating toggle

    bindsym $mod+1 workspace 1
    bindsym $mod+2 workspace 2
    bindsym $mod+3 workspace 3
    bindsym $mod+4 workspace 4
    bindsym $mod+5 workspace 5
    bindsym $mod+6 workspace 6
    bindsym $mod+7 workspace 7

    bindsym $mod+Shift+1 move container to workspace 1
    bindsym $mod+Shift+2 move container to workspace 2
    bindsym $mod+Shift+3 move container to workspace 3
    bindsym $mod+Shift+4 move container to workspace 4
    bindsym $mod+Shift+5 move container to workspace 5
    bindsym $mod+Shift+6 move container to workspace 6
    bindsym $mod+Shift+7 move container to workspace 7

    bindsym --locked XF86AudioRaiseVolume exec \
      ${pkgs.scripts.soundTools}/bin/stools vol up 5
    bindsym --locked XF86AudioLowerVolume exec \
      ${pkgs.scripts.soundTools}/bin/stools vol down 5
    bindsym --locked XF86AudioMute exec \
      ${pkgs.scripts.soundTools}/bin/stools vol toggle

    bindsym $mod+Shift+r ${pkgs.flameshot}/bin/flameshot gui

    smart_borders on
    default_border pixel 2
    output eDP-0 scale 1

    for_window [app_id="steam"] floating enable
    for_window [app_id="gimp"] floating enable
    for_window [app_id="org.keepassxc.KeePassXC"] floating enable
    for_window [app_id="virt-manager"] floating enable
    for_window [app_id="nemo"] floating enable
    for_window [app_id="com.nextcloud.desktopclient.nextcloud"] floating enable

    input "type:touchpad" {
      dwt enabled
      tap enabled
      natural_scroll enabled
      drag enabled
    }

    input "type:keyboard" {
      xkb_layout dk
    }
  '';
in {
  options.ki.graphical.wayland = {
    enable = mkEnableOption "Enable Wayland";

    type = mkOption {
      type = types.enum ["sway" "dwl"];
      description = "Which DE/WM to use, currently `sway` and `[dwl]`";
    };

    swaybg = {
      enable = mkEnableOption "Enable background [swaybg]";

      pkg = mkOption {
        type = types.package;
        description = "Package to use for swaybg";
      };

      image = mkOption {
        type = types.path;
        description = "Path to image file used for the background";
      };

      mode = mkOption {
        type = types.enum ["center" "fill" "fit" "stretch" "tile"];
        description = "Scaling mode for the background";
      };
    };

    fehbg = {
      enable = mkEnableOption "Enable background [feh]";

      pkg = mkOption {
        type = types.package;
        description = "Package to use for feh";
      };

      image = mkOption {
        type = types.path;
        description = "Path to image file used for the background";
      };

      mode = mkOption {
        type = types.enum ["tile" "center" "max" "fill"];
        description = "Scaling mode for the background";
      };
    };

    bar = {
      enable = mkEnableOption "Enable status bar [waybar]";

      pkg = mkOption {
        type = types.package;
        description = "Package to be used for waybar";
      };
    };

    lock = {
      enable = mkEnableOption "Enable screen locking. MUST enable it on system as well for PAMd [swaylock]";
    };
  };

  config = (mkIf cfg.enable) {
    assertions = [
      {
        assertion = systemCfg.graphical.wayland.enable;
        message = "To enable Wayland for user, it must be enabled for system";
      }
    ];

    home.packages = with pkgs; [
      (
        if (cfg.type == "sway")
        then sway
        else dwlKi
      )
      alacritty
      bemenu
      wl-clipboard
      libappindicator-gtk3
      mako
      (
        if cfg.swaybg.enable
        then swaybg
        else feh
      )
      (assert systemCfg.graphical.wayland.swaylock-pam; (
        if cfg.lock.enable
        then swaylock
        else null
      ))
    ];

    # Electron apps look blurry and scaled incorrectly without the added `exec` options.
    xdg.desktopEntries = {
      obsidian = {
        name = "Obsidian";
        terminal = false;
        mimeType = ["x-scheme-handler/obsidian"];
        categories = ["Office"];
        type = "Application";
        exec = "obsidian -enable-features=UseOzonePlatform -ozone-platform=wayland %u";
        icon = "obsidian";
      };

      element = {
        name = "Element";
        terminal = false;
        mimeType = ["x-scheme-handler/element"];
        categories = ["Network" "InstantMessaging" "Chat"];
        type = "Application";
        exec = "element-desktop -enable-features=UseOzonePlatform -ozone-platform=wayland %u";
        icon = "element";
      };
    };

    home.file = {
      ".winitrc" = {
        executable = true;
        text = ''
          # This file was automatically generated by Nix, DO NOT EDIT, YOUR CHANGES WILL NOT PERSIST.
          . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"

          # Enable Wayland support for Firefox
          export MOZ_ENABLE_WAYLAND=1
          export MOZ_NABLE_XINPUT2=1
          export XDG_CURRENT_DESKTOP=sway
          export TERMINAL=alacritty

          ${
            if (cfg.type == "sway")
            then ''
              ${pkgs.sway}/bin/sway
            ''
            else ''
              ${dwlKi}/bin/dwl
            ''
          }
          wait $!
          systemctl --user stop graphical-session.target
          systemctl --user stop graphical-session-pre.target

          # Wait until the units actually stop
          while [ -n "$(systemctl --user --no-legend --state=deactivating list-units)" ];
          do
            sleep 0.5
          done
        '';
      };
    };

    xdg.configFile = {
      "sway/config" = {
        text = swayConfig;
      };
    };

    systemd.user.targets = {
      dwl-session = mkIf (cfg.type == "dwl") {
        Unit = {
          Description = "Dwl compositor session";
          Documentation = ["man:systemd.special(7)"];
          BindsTo = ["wayland-session.target"];
          After = ["wayland-session.target"];
        };
      };

      sway-session = mkIf (cfg.type == "sway") {
        Unit = {
          Description = "Sway compositor session";
          Documentation = ["man:systemd.special(7)"];
          BindsTo = ["wayland-session.target"];
          After = ["wayland-session.target"];
        };
      };

      wayland-session = {
        Unit = {
          Description = "Wayland session";
          BindsTo = ["graphical-session.target"];
          After = ["graphical-session.target"];
        };
      };
    };

    systemd.user.services.swaybg = mkIf cfg.swaybg.enable {
      Unit = {
        Description = "swaybg background service";
        Documentation = ["man:swaybg(1)"];
        BindsTo = ["wayland-session.target"];
        After = ["wayland-session.target"];
      };

      Service = {
        ExecStart = "${cfg.swaybg.pkg}/bin/swaybg --image ${cfg.swaybg.image} --mode ${cfg.swaybg.mode}";
      };

      Install = {
        WantedBy = ["wayland-session.target"];
      };
    };

    systemd.user.services.fehbg = mkIf cfg.fehbg.enable {
      Unit = {
        Description = "Feh background service";
        Documentation = ["man:feh(1)"];
        BindsTo = ["wayland-session.target"];
        After = ["wayland-session.target"];
      };

      Service = {
        ExecStart = "${cfg.fehbg.pkg}/bin/feh --bg-${cfg.fehbg.mode} ${cfg.fehbg.image}";
      };

      Install = {
        WantedBy = ["wayland-session.target"];
      };
    };

    programs.waybar = mkIf cfg.bar.enable {
      enable = true;
      package = cfg.bar.pkg;
      settings = [
        {
          layer = "bottom";
          position = "top";
          height = 15;
          gtk-layer-shell = true;

          modules-left = [
            "sway/workspaces"
            "sway/mode"
          ];

          modules-center = ["clock"];

          modules-right = [
            "pulseaudio"
            "network"
            "cpu"
            "memory"
            "backlight"
            "battery"
            "tray"
          ];

          "sway/workspaces" = {
            disable-scroll = true;
            all-outputs = true;
            format = "{name}: {icon}";
            format-icons = {
              "1" = "";
              "2" = "";
              "3" = "";
              "4" = "";
              "5" = "";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };

          "sway/mode" = {
            format = ''<span style="italic">{}</span>'';
          };

          tray = {
            icon-size = 15;
            spacing = 6;
          };

          clock = {
            tooltip-format = "{:%Y-%m-%d | %H:%M}";
            format-alt = "{:%Y-%m-%d}";
          };

          cpu = {
            format = "CPU: {usage}%";
          };

          memory = {
            format = "RAM: {}%";
          };

          backlight = {
            device = "acpi_video1";
            format = "{percent}% {icon}";
            format-icons = ["" ""];
          };

          battery = {
            states = {
              good = 95;
              warning = 30;
              critical = 15;
            };
            format = "{capacity}% {icon}";
            format-icons = ["" "" "" "" ""];
          };

          network = {
            format-wifi = "{essid} [{signalStrength}%] ";
            format-ethernet = "{ifname}: {ipaddr}/{cidr} ";
            format-disconnected = "Disconnected ⚠";
          };

          pulseaudio = {
            format = "{volume}% {icon}";
            format-bluetooth = "{volume}% {icon}";
            format-muted = "";
            format-icons = {
              headphones = "";
              handsfree = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = ["" ""];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
          };
        }
      ];
      style = ''
        * {
            font-size: 12px;
            font-family: monospace;
        }

        window#waybar {
            background: rgba(36, 40, 59, 0.00);
            color: #cfc9c2;
        }

        #custom-right-arrow-dark, #custom-left-arrow-dark {
            color: #1a1a1a;
        }
        #custom-right-arrow-light, #custom-left-arrow-light {
            color: #292b2e;
            background: #1a1a1a;
        }

        #workspaces, #network, #clock, #clock.1, #clock.2, #clock.3, #pulseaudio, #backlight, #memory, #cpu, #temperature, #battery, #tray {
            background: rgba(26, 27, 38, 0.35);
        }

        #workspaces button {
            padding: 0 2px;
            color: #cfc9c2;
        }
        #workspaces button.focused {
            background: rgba(65, 72, 104, 0.6);
        }
        #workspaces button:hover {
            box-shadow: inherit;
            text-shadow: inherit;
        }
        #workspaces button:hover {
            background: rgba(26, 26, 26, 0.8);
            border: #1a1a1a;
            padding: 0 3px;
        }

        #pulseaudio {
            color: #f7768e;
        }
        #network {
            color: #ff9e64;
            padding: 0 13px;
        }
        #cpu {
            color: #e0af68;
        }
        #memory {
            color: #9ece6a;
        }
        #backlight {
            color: #2ac3de;
        }
        #battery {
            color: #7aa2f7;
        }
        #tray {
            padding: 0 5px;
        }

        #clock, #pulseaudio, #backlight, #memory, #cpu, #temperature, #battery {
            padding: 0 10px;
        }

      '';
      systemd.enable = true;
    };

    systemd.user.services.waybar = mkIf cfg.bar.enable {
      Unit.BindsTo = lib.mkForce ["wayland-session.target"];
      Unit.After = lib.mkForce ["wayland-session.target"];
      Install.WantedBy = lib.mkForce ["wayland-session.target"];
    };
  };
}
