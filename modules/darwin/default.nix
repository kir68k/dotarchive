{inputs}: {
  config,
  pkgs,
  lib,
  darwin,
  ...
}: {
  imports = [
    ./applications
    ./dev
  ];
}