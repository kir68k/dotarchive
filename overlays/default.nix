{
  pkgs,
  nur,
  scripts,
  system,
  lib,
  dwl-flake,
  impermanence,
  agenix,
  homeage,
}: let
  dwl-config = builtins.readFile ./dwl-config.c;
in {
  overlays = [
    nur.overlay
    scripts.overlay
    dwl-flake.overlay."${system}"
    (final: prev: {
      agenix-cli = agenix.defaultPackage."${system}";
      inherit homeage impermanence;
    })
  ];
}
