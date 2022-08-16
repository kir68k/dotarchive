{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./alacritty
    ./applications
    ./git
    ./graphical
    ./ssh
    ./zsh
  ];
}
