{inputs}: {
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.core;
in {
  options.ki.core = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable core options";
    };

    time = mkOption {
      type = types.enum [ "cph" "wrs" ];
      default = "cph";
      description = "Time zone";
    };

    locale = mkOption {
      type = types.enum [ 
        "en-dk" "en-pl" "en-us"
        "da-dk" "pl-pl"
      ];
      default = "en-dk";
      description = "System locale";
    };
  };

  config = mkIf (cfg.enable) {
    i18n.defaultLocale =
      if (cfg.locale == "en-dk")
      then "en_DK.UTF-8"
        else if (cfg.time == "en-pl")
        then "en-PL.UTF-8"
        else if (cfg.time == "da-dk")
        then "da_DK.UTF-8"
        else if (cfg.time == "pl-pl")
        then "pl_PL.UTF-8"
      else "en_US.UTF-8";

    time.timeZone =
      if (cfg.time == "cph")
      then "Europe/Copenhagen"
        else if (cfg.time == "wrs")
        then "Europe/Warsaw"
      else "UTC";

    hardware.enableRedistributableFirmware = lib.mkDefault true;

    # Search paths/registries
    # https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/166d6ebd9f0de03afc98060ac92cba9c71cfe550/lib/options.nix
    # Context thread: https://github.com/gytis-ivaskevicius/flake-utils-plus/blob/166d6ebd9f0de03afc98060ac92cba9c71cfe550/lib/options.nix
    nix = let
      flakes =
        filterAttrs
        (name: value: value ? outputs)
        inputs;
      flakesWithPkgs =
        filterAttrs
        (name: value:
          value.outputs ? legacyPackages || value.outputs ? packages)
        flakes;
      nixRegistry = builtins.mapAttrs (name: v: { flake = v; }) flakes;
    in {
      registry = nixRegistry;
      nixPath =
        mapAttrsToList
        (name: _: "${name}=/etc/nix/inputs/${name}")
        flakesWithPkgs;
      package = pkgs.nixUnstable;
      gc = {
        persistent = true;
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    };
    environment = {
      sessionVariables = {
        EDITOR = "vim";
      };
      etc =
        mapAttrs'
        (name: value: {
          name = "nix/inputs/${name}";
          value = { source = value.outPath; };
        })
        inputs;

      shells = [ pkgs.zsh pkgs.bash ];
      # ZSH Completions
      pathsToLink = [ "/share/zsh" ];
      systemPackages = with pkgs; [
        # Shell
        zsh

        # Misc utils
        inxi
        usbutils
        neofetch
        unzip
        p7zip
        exa

        # secrets
        rage
        agenix-cli

        # Processors
        gnused
        gawk
        jq

        # Downloaders
        wget
        curl
        aria2

        # Monitors
        htop
        acpi
        pstree

        # VCS
        git

        # Nix utils
        patchelf
        nix-index
        nix-tree
        manix

        # Base text editor, vimHugeX as the name says is a bit... huge, including Python support, Nix syntax higlighting, and such.
        vimHugeX

        # Scripts
        scripts.sysTools

        man-pages
        man-pages-posix
      ];
    };

    users.users.root = {
      name = "root";
      initialHashedPassword = "$6$mxWfUQqxuiFndTXL$bCn1ui5qRnQ6aXf3Zw/hJGr9J4HXhQuYAd0kzFk8ms/yxMX/0.geZ2cuRWimAJR20qiEvRJ9BbGWGw.spc4KU.";
    };

    documentation = {
      enable = true;
      dev.enable = true;
      man = {
        enable = true;
        generateCaches = true;
      };
      info.enable = true;
      nixos.enable = true;
    };
  };
}
