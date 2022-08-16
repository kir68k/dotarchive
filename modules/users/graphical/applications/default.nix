{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./core.nix
    ./firefox.nix
    ./libreoffice.nix
    ./multimedia.nix
    ./nextcloud.nix
  ];
}
