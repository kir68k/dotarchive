{
  pkgs,
  scripts,
  system,
  lib,
  darwin,
}: {
  overlays = [
    scripts.overlay
  ];
}