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
      # TODO fix this, prob will need to make it into a full personal pkg
      #lidarr = prev.lidarr.overrideAttrs (old: rec {
      #  pname = "lidarr";
      #  version = "1.0.2.2592";
      #
      #  src = pkgs.fetchurl {
      #    url = "https://github.com/Lidarr/Lidarr/releases/download/v${version}/Lidarr.master.${version}.linux-core-x64.tar.gz";
      #    sha256 = "iuI24gT7/RFZ9xc4csd+zWEzPSPsxqYY5F+78IWRjxQ=";
      #  };
      #});
    })
  ];
}
