{
  description = "Personal nix-darwin configurations";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-darwin";

    inherit (nixpkgs) lib;

    util = import ./lib {
      inherit system nixpkgs pkgs lib overlays inputs home-manager darwin;
    };

    scripts = import ./scripts {
      inherit pkgs lib darwin;
    };

    inherit
      (import ./overlays {
        inherit
          system
          pkgs
          lib
          scripts
          darwin
          ;
      })
      overlays
      ;

    inherit (util) user;
    inherit (util) host;
    inherit (util) utils;

    pkgs = import nixpkgs {
      inherit system darwin overlays;
      config = {
        allowUnfree = true;
      };
    };

    defaultConfig = {
      applications.core.enable = true;
    };

    rvConfig = {
      applications = {
        core.enable = true;
      };

      dev = {
        enable = true;
        languages.haskell.enable = true;
      };
    };
  in {
    hmConfigrations = {
      lapic = user.mkHMUser rec {
        username = "lapic";
        userConfig = {
          app.enable = true;
          direnv = {
            enable = true;
            nix.enable = true;
          };
          git = {
            enable = true;
            userName = "Lλpic";
            userMail = "lapic@kirinsst.xyz";
          };
          ssh = {
            enable = true;
            git = {
              enable = true;
              domain = "git.kirinsst.xyz";
              keyPath = "/Users/${username}/.ssh/streamea";
              port = 42069;
            };
          };
          zsh = {
            enable = true;
            starship.enable = true;
          };
        };
      };
    };

    darwinConfigurations = {
      relativity = host.mkHost {
        name = "relativity";
        systemConfig = rvConfig;
        cpuCores = 8;
        stateVersion = 4;
      };
    };
  };
}
