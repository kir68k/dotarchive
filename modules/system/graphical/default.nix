{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./shared.nix
    ./wayland.nix
    ./xorg.nix
  ];
}
