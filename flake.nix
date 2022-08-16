{
  description = "Ki's system configurations";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    homeage = {
      url = "github:jordanisaacs/homeage/activatecheck";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dwl-flake = {
      url = "git+https://git.kirinsst.xyz/kir/dwl-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    impermanence,
    agenix,
    nur,
    home-manager,
    homeage,
    dwl-flake,
    ...
  } @ inputs: let
    inherit (nixpkgs) lib;

    util = import ./lib {
      inherit system nixpkgs pkgs lib overlays inputs home-manager;
    };

    scripts = import ./scripts {
      inherit pkgs lib;
    };

    inherit
      (import ./overlays {
        inherit
          system
          pkgs
          lib
          nur
          agenix
          scripts
          dwl-flake
          impermanence
          homeage
          ;
      })
      overlays
      ;

    inherit (util) user;
    inherit (util) host;
    inherit (util) utils;

    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnfree = true; # Do I need? TODO
      };
    };

    system = "x86_64-linux";

    authorizedKeys = ''
      ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGwY2ekV5vrjsFMLIyGz3K2aosqCs1BF95tfEpcuNzpI lapic@kirinsst.xyz
    '';

    authorizedKeyFiles = pkgs.writeTextFile {
      name = "authorizedKeys";
      text = authorizedKeys;
    };

    defaultClientConfig = {
      core.enable = true;
      boot.type = "efi-crypt";
      gnome = {
        enable = true;
        keyring = {
          enable = true;
        };
      };
      networking = {
        firewall.enable = true;
        networkmanager.enable = true;
      };
      graphical = {
        enable = true;
        xorg.enable = false;
        wayland = {
          enable = true;
          swaylock-pam = true;
        };
      };
      connectivity = {
        bluetooth.enable = true;
        printing.enable = true;
        sound.enable = true;
      };
    };

    laptopConfig = utils.recursiveMerge [
      defaultClientConfig
      {
        laptop.enable = true;
        #secrets.identityPaths = [ "" ];
        networking.interfaces = ["enp0s31f6" "wlp3s0"];
      }
    ];

    rvConfig = utils.recursiveMerge [
      defaultClientConfig
      {
        laptop.enable = true;
        networking.interfaces = ["wlp3s0"];
        core.time = "cph";
        greetd.enable = true;
        tty = {
          enable = true;
          enableEarly = true;
          font = {
            path = "${pkgs.terminus_font}/share/consolefonts/ter-u32n.psf.gz";
            pkg = with pkgs; terminus_font;
          };
          kbdLayout = "dk";
        };
        relativity = {
          enable = true;
          fprint.enable = true;
        };
        virtualisation = {
          enable = true;
          lxc.enable = true;
          libvirt.enable = true;
        };
        applications = {
          steam.enable = true;
        };
        #secrets.identityPaths = [ secrets.age.system.relativity.privateKeyPath ];
      }
    ];

    defaultUser = {
      name = "ki";
      groups = ["wheel"];
      uid = 1000;
      hashedPassword = "$6$grTXztDvxt5FaAdh$owQZ5ncLn07tMCx/wvGfXUCSydht.N5Hqs181dHKaTn0mxX4je9ZRfVZf/zxJ7m9llodPxUvkoPRnV.iZrqTB0";
      shell = pkgs.zsh;
    };

    defaultUsers = [defaultUser];

    defaultDesktopUser =
      defaultUser
      // {
        groups = defaultUser.groups ++ ["networkmanager" "video" "libvirtd" "kvm"];
      };
  in {
    installMedia = {
      kde = host.mkISO {
        name = "nixos";
        kernelPackage = pkgs.linuxPackages_latest;
        initrdMods = ["xhci_pci" "ahci" "usb_storage" "sd_mod" "nvme" "usbhid"];
        kernelMods = ["kvm-intel" "kvm-amd"];
        kernelParams = [];
        systemConfig = {};
      };
    };

    homeManagerConfigurations = {
      kirinsst = user.mkHMUser {
        username = "kirinsst";
        userConfig = {
          zsh.enable = true;
        };
      };

      ki = user.mkHMUser {
        username = "ki";
        userConfig = {
          graphical = {
            applications = {
              enable = true;
              firefox.enable = true;
              nextcloud.enable = true;
              libreoffice.enable = true;
            };
            wayland = {
              enable = true;
              type = "sway";
              swaybg = {
                enable = true;
                image = ./modules/users/graphical/wallpapers/bg3.png;
              };
              bar.enable = true;
              lock.enable = true;
            };
            xorg = {
              enable = false;
              type = "xmonad";
            };
          };
          applications.enable = true;
          zsh.enable = true;
          alacritty.enable = true;
          git.enable = true;
          ssh = {
            enable = true;
            git.enable = true;
          };
        };
      };
    };

    nixosConfigurations = {
      relativity = host.mkHost {
        name = "relativity";
        kernelPackage = pkgs.linuxPackages_zen;
        initrdMods = ["xhci_pci" "nvme" "usb_storage" "sd_mod" "thunderbolt"];
        kernelMods = ["kvm-intel"];
        kernelParams = [];
        kernelPatches = [];
        systemConfig = rvConfig;
        users = [defaultDesktopUser];
        cpuCores = 8;
        stateVersion = "22.11"; # Installed from unstable channel ISO, 22.11pre... at the time
      };

      test-vm = host.mkHost {
        name = "test-vm";
        kernelPackage = pkgs.linuxPackages_latest;
        initrdMods = ["xhci_pci" "nvme" "usb_storage" "sd_mod"];
        kernelMods = ["kvm-intel"];
        kernelParams = [];
        kernelPatches = [];
        systemConfig = defaultClientConfig;
        users = [defaultDesktopUser];
        cpuCores = 4;
        stateVersion = "22.11";
      };
    };
  };
}
