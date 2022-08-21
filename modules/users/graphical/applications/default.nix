{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./core.nix
    ./firefox.nix
    ./java.nix
    ./libreoffice.nix
    ./multimedia.nix
    ./nextcloud.nix
  ];
}
