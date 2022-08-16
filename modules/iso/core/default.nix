{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  system.stateVersion = "22.11";

  nix = {
    extraOptions = "experimental-features = nix-command flakes";
    gc = {
      automatic = true;
      options = "--delete-older-than 3d";
    };
    package = pkgs.nixFlakes;
  };

  # Make this config an ISO config
  imports = [ "${modulesPath}/installer/cd-dvd/iso-image.nix" ];

  networking.networkmanager.enable = true;
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    wget
    curl
    vimHugeX
    pciutils
    killall
    bind
    dmidecode
    neofetch
    htop
    bat
    unzip
    file
    zip
    p7zip
    usbutils
    strace
    ltrace
    android-tools # adb
    android-udev-rules

    # Setup scripts
    scripts.setuptools

    # vcs
    git
    git-crypt

    # Storage utils
    cryptsetup
    gptfdisk
    zsh
    iotop
    nvme-cli
    pstree
    acpi
    nix-index
  ];
}
