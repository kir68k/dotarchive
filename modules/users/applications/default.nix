{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications.nix
    ./windows.nix
  ];
}
