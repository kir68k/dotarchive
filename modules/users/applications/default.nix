{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications.nix
    ./tmux.nix
    ./windows.nix
  ];
}
