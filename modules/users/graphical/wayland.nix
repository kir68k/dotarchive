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

  wayfireStartup = pkgs.writeShellScriptBin "wayfire-setup" ''
    if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
      eval $(dbus-launch --exit-with-session --sh-syntax)
    fi

    ## https://bbs.archlinux.org/viewtopic.php?id=224652
    if command -v dbus-update-activation-environment >/dev/null 2>&1; then
      dbus-update-activation-environment --systemd --all
    fi

    systemctl --user restart xdg-desktop-portal-gtk.service
    systemctl --user start wayfire-session.target
  '';
  wayfireConfig = let
    term = "${pkgs.alacritty}/bin/alacritty --config-file=/home/ki/.config/alacritty/alacritty.yml";
  in ''
    [autostart]
    startup = ${wayfireStartup}/bin/wayfire-setup
    autostart_wf_shell = false
    notifications = mako

    [input]
    xkb_layout = dk
    xkb_variant = nodeadkeys
    cursor_size = 24

    ${
      if (systemCfg.relativity.enable)
      then ''
        [output:eDP-1]
        mode = 2560x1440@59998001 # i feel weird not having a decimal dot here ;_;
        position = 0,0
        transform = normal
        scale = 2.000000
      ''
      else ""
    }

    [core]
    plugins = \
      alpha \
      autostart \
      command \
      criteria \
      decoration \
      expo \
      fast-switcher \
      grid \
      move \
      oswitch \
      place \
      resize \
      switcher \
      vswitch \
      window-rules \
      wm-actions \
      wobbly

    close_top_view = <super> KEY_Q | <alt> KEY_F4

    vwidth = 3
    vheight = 3

    preferred_decoration_mode = server

    # I'll be honest I'd prefer having hexadecimals here
    # Trying to get it right when you can only work through a fraction is more annoying
    [decoration]
    active_color = 0.25 0.3 0.35 1.0
    button_order = minimize close
    border_size = ${
      if (systemCfg.relativity.enable)
      then "4"
      else "2"
    }
    inactive_color = 0.1 0.11 0.19 1.0
    font = IBM Plex Mono

    title_height = 15

    ignore_views = app_id is "Firefox"
    ignore_views = app_id is "Element"

    [move]
    activate = <super> BTN_LEFT

    [resize]
    activate = <super> BTN_RIGHT

    [alpha]
    modifier = <super> <alt>


    [command]
    binding_terminal = <super> KEY_ENTER
    command_terminal = ${term}

    binding_launcher = <super> KEY_SPACE
    command_launcher = ${pkgs.j4-dmenu-desktop}/bin/j4-dmenu-desktop --dmenu="BEMENU_SCALE=2 ${pkgs.bemenu}/bin/bemenu -i -l 8 --scrollbar autohide" --term="$term" --no-generic

    binding_logout = <super> KEY_SHIFT KEY_Q
    command_logout = wlogout

    binding_screenshot = KEY_PRINT
    command_screenshot = grim $(date '+%F_%T').png
    binding_screenshot_interactive = <shift> KEY_PRINT
    command_screenshot_interactive = slurp | grim -g - $(date '+%F_%T').png

    repeatable_binding_volume_up = KEY_VOLUMEUP
    command_volume_up = ${pkgs.scripts.soundTools}/bin/stools vol up 5
    repeatable_binding_volume_down = KEY_VOLUMEDOWN
    command_volume_down = ${pkgs.scripts.soundTools}/bin/stools vol down 5
    binding_mute = KEY_MUTE
    command_mute = ${pkgs.scripts.soundTools}/bin/stools vol toggle

    repeatable_binding_light_up = KEY_BRIGHTNESSUP
    command_light_up = light -A 5
    repeatable_binding_light_down = KEY_BRIGHTNESSDOWN
    command_light_down = light -U 5

    [wm-actions]
    toggle_fullscreen = <super> KEY_F
    toggle_always_on_top = <super> KEY_X
    toggle_sticky = <super> <shift> KEY_X

    [switcher]
    next_view = <alt> KEY_TAB
    prev_view = <alt> <shift> KEY_TAB

    [fast-switcher]
    activate = <alt> KEY_ESC

    [vswitch]
    binding_left = <super> KEY_H
    binding_down = <super> KEY_J
    binding_up = <super> KEY_K
    binding_right = <super> KEY_L
    with_win_left = <super> <shift> KEY_H
    with_win_down = <super> <shift> KEY_J
    with_win_up = <super> <shift> KEY_K
    with-win_right = <super> <shift> KEY_L

    [expo]
    toggle = <super>

    select_workspace_1 = KEY_1
    select_workspace_2 = KEY_2
    select_workspace_3 = KEY_3
    select_workspace_4 = KEY_4
    select_workspace_5 = KEY_5
    select_workspace_6 = KEY_6
    select_workspace_7 = KEY_7
    select_workspace_8 = KEY_8
    select_workspace_9 = KEY_9

    [oswitch]
    next_output = <super> KEY_O
    next_output_with_win = <super> <shift> KEY_O
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
    bindsym $mod+8 workspace 8
    bindsym $mod+9 workspace 9

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
    gaps inner 10
    client.focused #c0caf5 #c0caf5 #c0caf5
    client.unfocused #24283b #24283b #24283b

    for_window [app_id="steam"] floating enable
    for_window [app_id="gimp"] floating enable
    for_window [app_id="org.keepassxc.KeePassXC"] floating enable
    for_window [app_id="virt-manager"] floating enable
    for_window [app_id="nemo"] floating enable
    for_window [app_id="xarchiver"] floating enable
    for_window [app_id="com.nextcloud.desktopclient.nextcloud"] floating enable
    for_window [app_id="org.inkscape.Inkscape"] floating enable

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
      type = types.enum ["dwl" "wayfire" "sway"];
      description = "Which DE/WM to use";
    };

    wlsunset = {
      enable = mkEnableOption "Enable color temperature switching [wlsunset]";

      pkg = mkOption {
        type = types.package;
        default = pkgs.wlsunset;
        description = "Package for wlsunset to use";
      };

      lat = mkOption {
        type = types.str;
        default = "40.0";
        description = "Your current latitude, between -90.0 and 90.0";
      };

      long = mkOption {
        type = types.str;
        default = "10.0";
        description = "Your current longitude, between -180.0 and 180.0";
      };
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

    swww = {
      enable = mkEnableOption "Enable background [swww]";

      pkg = mkOption {
        type = types.package;
        default = with pkgs; kipkgs.swww;
        description = "Package to use for swww";
      };

      image = mkOption {
        type = types.path;
        description = "Path to the image file used for the background";
      };

      transition = {
        step = mkOption {
          type = types.ints.between 1 255;
          default = 20;
          description = "Control how smoothly the transition will happen";
        };
        framerate = mkOption {
          type = types.ints.between 1 255;
          default = 30;
          description = "Control the transition's framerate";
        };

        type = mkOption {
          type = types.str;
          default = "center";
          description = "Transition effect";
        };
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
        else if (cfg.type == "wayfire")
        then wayfire
        else dwlKi
      )
      alacritty
      bemenu
      wl-clipboard
      libappindicator-gtk3
      mako
      wlogout
      grim
      slurp
      (
        wlr-randr.overrideAttrs (_: rec {
          pname = "wlr-randr";
          version = "2022-06-30";

          src = fetchFromSourcehut {
            owner = "~emersion";
            repo = "${pname}";
            rev = "d17786cf05f22a5ccbd65ce0cfdf0bab1bfc0623";
            sha512 = "dTfj36za1afyMqoJxnkj2q1OeYaA7auUIK1CQbxumlP0eTD0/WsnqioYSgLlNsQhdjPXXNvqd59cXXhg91Jvlg==";
          };
        })
      )
      (
        if cfg.swaybg.enable
        then swaybg
        else if cfg.swww.enable
        then kipkgs.swww
        else if cfg.feh.enable
        then feh
        else null
      )
      (assert systemCfg.graphical.wayland.swaylock-pam; (
        if cfg.lock.enable
        then swaylock
        else null
      ))
    ];

    services.wlsunset = mkIf cfg.wlsunset.enable {
      enable = true;
      package = cfg.wlsunset.pkg;
      latitude = cfg.wlsunset.lat;
      longitude = cfg.wlsunset.long;
      systemdTarget = "wayland-session.target";
    };

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

      element-desktop = {
        name = "Element";
        terminal = false;
        mimeType = ["x-scheme-handler/element"];
        categories = ["Network" "InstantMessaging" "Chat"];
        type = "Application";
        exec = "element-desktop -enable-features=UseOzonePlatform,WaylandWindowDecorations -ozone-platform=wayland %u";
        icon = "element";
      };

      spotify = {
        name = "Spotify";
        terminal = false;
        mimeType = ["x-scheme-handler/spotify"];
        categories = ["Audio" "Music" "Player" "AudioVideo"];
        type = "Application";
        exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
        icon = "spotify-client";
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
            else if (cfg.type == "wayfire")
            then ''
              ${pkgs.wayfire}/bin/wayfire
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
      "sway/config" = mkIf (cfg.type == "sway") {
        text = swayConfig;
      };

      "wayfire.ini" = mkIf (cfg.type == "wayfire") {
        text = wayfireConfig;
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

      wayfire-session = mkIf (cfg.type == "wayfire") {
        Unit = {
          Description = "Wayfire compositor session";
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

    systemd.user.services.swww-init = with pkgs;
      mkIf (cfg.swww.enable) {
        Unit = {
          Description = "swww initialization service";
          Documentation = ["https://github.com/Horus645/swww/blob/main/README.md#usage"];
          BindsTo = ["wayland-session.target"];
          After = ["wayland-session.target"];
          Before = ["swww.service"];
        };
        Service = {
          ExecStartPre = "${coreutils}/bin/sleep 0.2"; # Seems to sometimes crash without this
          ExecStart = "${kipkgs.swww}/bin/swww init --no-daemon";
        };
        Install = {
          WantedBy = ["wayland-session.target" "swww.service"];
        };
      };
    systemd.user.services.swww = with pkgs;
      mkIf (cfg.swww.enable) {
        Unit = {
          Description = "swww background service";
          Documentation = ["https://github.com/Horus645/swww/blob/main/README.md"];
          BindsTo = ["wayland-session.target"];
          After = ["wayland-session.target" "swww-init.service"];
          Requires = ["swww-init.service"];
        };
        Service = {
          ExecStart = "${kipkgs.swww}/bin/swww img ${cfg.swww.image} --transition-step ${toString cfg.swww.transition.step} --transition-fps ${toString cfg.swww.transition.framerate} --transition-type ${cfg.swww.transition.type}";
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
            background: #24283b;
        }
        #workspaces button:hover {
            background: rgba(26, 26, 26, 0.8);
            border: #1a1a1a;
            padding: 0 3px;
        }

        #pulseaudio {
            color: #c0caf5;
        }
        #network {
            color: #c0caf5;
            padding: 0 13px;
        }
        #cpu {
            color: #c0caf5;
        }
        #memory {
            color: #c0caf5;
        }
        #backlight {
            color: #c0caf5;
        }
        #battery {
            color: #c0caf5;
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
