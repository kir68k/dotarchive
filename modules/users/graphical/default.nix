{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications
    ./config.nix
    ./shared.nix
    ./wayland.nix
    ./xorg.nix
  ];
}
