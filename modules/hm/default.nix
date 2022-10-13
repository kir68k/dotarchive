{
  config,
  pkgs,
  lib,
  darwin,
  ...
}: {
  imports = [
    ./app
    #./direnv
    ./git
    ./ssh
    ./zsh
  ];
}
