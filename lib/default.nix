{
  nixpkgs,
  pkgs,
  home-manager,
  system,
  lib,
  overlays,
  inputs,
  ...
}: rec {
  utils = pkgs.callPackage ./utils.nix { self = inputs.self; };
  user = import ./user.nix { inherit nixpkgs pkgs lib system overlays home-manager; };
  host = import ./host.nix { inherit inputs user utils lib system pkgs; };
}
