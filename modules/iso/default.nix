{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./core
    ./desktop
    ./user
  ];
}
