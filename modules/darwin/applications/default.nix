{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:

with lib; let
  cfg = config.ki.applications;
in {
  options.ki.applications = {
    core.enable = mkEnableOption "Add core packages to global env";
  };

  config = mkIf cfg.core.enable {
    environment.systemPackages = with pkgs; [
      manix nix-index
    ];

    programs.zsh = {
      enable = true;
      enableCompletion = mkDefault true;
      enableSyntaxHighlighting = mkDefault true;
    };
  };
}