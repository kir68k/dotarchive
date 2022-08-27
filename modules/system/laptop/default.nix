{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.laptop;
in {
  options.ki.laptop = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether to enable laptop settings";
    };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      acpid
      powertop
    ];

    programs = {
      light.enable = true;
    };

    services = {
      acpid = {
        enable = true;
        handlers = {
          # Volume isn't controllable through acpid as PipeWire/PulseAudio runs as a user service and acpid as a system service
          brightness-down = {
            event = "video/brightnessdown*";
            action = "${pkgs.light}/bin/light -U 4";
          };
          brightness-up = {
            event = "video/brightnessup";
            action = "${pkgs.light}/bin/light -A 4";
          };
          ac-power = {
            event = "ac_adapter/*";
            action = ''
              vals=($1) # space separated string to array of multiple values
              case ''${vals[3]} in
                00000000)
                  max_bright=30
                  curr_bright=$(echo $(${pkgs.light}/bin/light -G) | xargs printf "%0.f")
                  ${pkgs.light}/bin/light -S $((curr_bright<max_bright ? curr_bright : max_bright))
                  ;;
                00000001)
                  ${pkgs.light}/bin/light -S 100
                ;;
              esac
            '';
          };
        };
      };

      tlp = {
        enable = true;
        settings =
          {
            "SOUND_POWER_SAVE_ON_AC" = 0;
            "SOUND_POWER_SAVE_ON_BAT" = 1;
            "SOUND_POWER_SAVE_CONTROLLER" = "Y";
            "DISK_APM_LEVEL_ON_AC" = "254 254";
            "DISK_APM_LEVEL_ON_BAT" = "128 128";
            "DISK_IOSCHED" = "mq-deadline mq-deadline";
            "SATA_LINKPWR_ON_AC" = "med_power_with_dipm max_performance";
            "SATA_LINKPWR_ON_BAT" = "min_power min_power";
            "MAX_LOST_WORK_SECS_ON_AC" = 15;
            "MAX_LOST_WORK_SECS_ON_BAT" = 60;
            "NMI_WATCHDOG" = 0;
            "WIFI_PWR_ON_AC" = "off";
            "WIFI_PWR_ON_BAT" = "on";
            "WOL_DISABLE" = "Y";
            "CPU_SCALING_GOVERNOR_ON_AC" = "performance";
            "CPU_SCALING_GOVERNOR_ON_BAT" = "schedutil";
            "CPU_MIN_PERF_ON_AC" = 0;
            "CPU_MAX_PERF_ON_AC" = 100;
            "CPU_MIN_PERF_ON_BAT" = 0;
            "CPU_MAX_PERF_ON_BAT" = 70;
            "CPU_BOOST_ON_AC" = 1;
            "CPU_BOOST_ON_BAT" = 0;
            "SCHED_POWERSAVE_ON_AC" = 0;
            "SCHED_POWERSAVE_ON_BAT" = 0; # Makes no sense setting this to `1` if we've set `schedutil` above.
            "RESTORE_DEVICE_STATE_ON_STARTUP" = 0;
            "RUNTIME_PM_ON_AC" = "on";
            "RUNTIME_PM_ON_BAT" = "auto";
            "PCIE_ASPM_ON_AC" = "default";
            "PCIE_ASPM_ON_BAT" = "powersupersave";
            "USB_AUTOSUSPEND" = 0;
          }
          // (
            if config.ki.relativity.enable == true
            then {
              "CPU_ENERGY_PERF_POLICY_ON_AC" = "performance";
              "CPU_ENERGY_PERF_POLICY_ON_BAT" = "schedutil";
              "PLATFORM_PROFILE_ON_AC" = "performance";
              "PLATFORM_PROFILE_ON_BAT" = "balanced";
              "CPU_HWP_DYN_BOOST_ON_AC" = 1;
              "CPU_HWP_DYN_BOOST_ON_BAT" = 0;
              "INTEL_GPU_MIN_FREQ_ON_AC" = 300;
              "INTEL_GPU_MIN_FREQ_ON_BAT" = 300;
              "INTEL_GPU_MAX_FREQ_ON_AC" = 800;
              "INTEL_GPU_MAX_FREQ_ON_BAT" = 800;
              "INTEL_GPU_BOOST_FREQ_ON_AC" = 1000;
              "INTEL_GPU_BOOST_FREQ_ON_BAT" = 1000;
            }
            else {}
          );
      };
    };
  };
}
