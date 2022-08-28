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
  kipkgs,
}: let
  dwl-config = builtins.readFile ./dwl-config.c;
in {
  overlays = [
    nur.overlay
    scripts.overlay
    dwl-flake.overlay."${system}"
    (final: prev: {
      agenix-cli = agenix.defaultPackage."${system}";
      kipkgs = kipkgs.packages."${system}";
      inherit homeage impermanence;
    })
  ];
}
