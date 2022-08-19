{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./alacritty
    ./applications
    ./direnv
    ./git
    ./graphical
    ./ssh
    ./zsh
  ];
}
