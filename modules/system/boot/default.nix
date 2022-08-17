{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.boot;
in {
  options.ki.boot = {
    type = mkOption {
      type = types.enum ["efi-crypt" "zfs-crypt"];
      default = null;
      description = "Layout of the system disk, options are `zfs-crypt` and `efi-crypt`";
    };

    hostId = mkOption {
      type = types.str;
      default = null;
      description = "Network Host ID, required for ZFS";
    };

    swapPartuuid = mkOption {
      type = types.str;
      default = null;
      description = "Partuuid of swap partition, required for ZFS";
    };

    plymouth = {
      enable = mkEnableOption "Enable Plymouth, a graphical drive decrypting program during boot time";
    };
  };

  config = let
    bootConfig = mkMerge [
      (mkIf (cfg.plymouth.enable) {
        boot.plymouth = {
          enable = true;
          font = "${pkgs.lato}/share/fonts/lato/Lato-Regular.ttf";
          theme = "spinfinity";
        };
      })
      (mkIf (cfg.type == "efi-crypt") {
        boot.loader = {
          efi = {
            canTouchEfiVariables = true;
            efiSysMountPoint = "/boot";
          };

          grub = {
            enable = true;
            devices = ["nodev"];
            efiSupport = true;
            useOSProber = true;
            version = 2;
            extraEntries = ''
              menuentry "Reboot" {
                reboot
              }

              menuentry "Shut down" {
                halt
              }
            '';
            extraConfig = mkIf (config.ki.relativity.enable) "i195.enable_psr=0";
          };
        };

        boot.initrd.luks.devices = {
          cryptkey = {
            device = "/dev/disk/by-label/NIXKEY";
          };

          cryptroot = {
            device = "/dev/disk/by-label/NIXROOT";
            keyFile = "/dev/mapper/cryptkey";
          };

          cryptswap = {
            device = "/dev/disk/by-label/NIXSWAP";
            keyFile = "/dev/mapper/cryptkey";
          };
        };

        fileSystems."/" = {
          device = "/dev/disk/by-label/DECNIXROOT";
          fsType = "xfs";
        };

        fileSystems."/boot" = {
          device = "/dev/disk/by-label/EFI";
          fsType = "vfat";
        };

        swapDevices = [
          {
            device = "/dev/disk/by-label/DECRYPTNIXSWAP";
          }
        ];
      })

      (mkIf (cfg.type == "zfs-crypt") {
        boot = {
          loader = {
            efi.canTouchEfiVariables = true;
            systemd-boot.enable = false;
            grub = {
              enable = true;
              version = 2;
              devices = ["/dev/disk/by-id/nvme-INTEL_SSDPEKNW010T8_BTNH910002TG1P0B"];
              efiSupport = true;
              zfsSupport = true;
              copyKernels = true; # Advised by the Nix wiki, prevents errors if there's a high number of hard links in the Nix store
            };
          };
          supportedFilesystems = ["zfs"];
          initrd.supportedFilesystems = ["zfs"];
          kernelParams = ["nohibernate"]; # ZFS does not like hibernation.. [https://github.com/openzfs/zfs/issues/260]
          zfs.requestEncryptionCredentials = true;
        };

        services.zfs.autoScrub.enable = true;
        networking.hostId = cfg.hostId;

        swapDevices = [
          {
            device = "/dev/disk/by-partuuid/${cfg.swapPartuuid}";
            randomEncryption = true;
          }
        ];
        fileSystems."/boot" = {
          device = "/dev/disk/by-label/EFI";
          fsType = "vfat";
        };
        fileSystems."/" = {
          device = "rpool/local/root";
          fsType = "zfs";
        };
        fileSystems."/nix" = {
          device = "rpool/local/nix";
          fsType = "zfs";
        };
        fileSystems."/home" = {
          device = "rpool/local/home";
          fsType = "zfs";
        };
        fileSystems."/persist" = {
          device = "rpool/persist/root";
          fsType = "zfs";
          neededForBoot = true;
        };
        fileSystems."/persist/home" = {
          device = "rpool/persist/home";
          fsType = "zfs";
          neededForBoot = true;
        };
      })
    ];
  in
    bootConfig;
}
