{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let 
  cfg = config.ki.direnv;
  tomlFormat = pkgs.formats.toml { };
in {
  options.ki.direnv = {
    enable = mkEnableOption "Enable direnv";

    nix = {
      enable = mkEnableOption "Enable nix integration through nix-direnv";
    };

    extraConfig = mkOption {
      type = tomlFormat.type;
      default = {};
      description = "Extra configuration passed to direnv's config file, gets passed as TOML values";
    };
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      config = cfg.extraConfig;
      nix-direnv.enable = true;
    };
  };
}