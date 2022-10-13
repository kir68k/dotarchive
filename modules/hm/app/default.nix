{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:

with lib; let
  cfg = config.ki.app;
in {
  options.ki.app = {
    enable = mkEnableOption "Add core (defined by me for myself) programs to user env";
    
    auxiliaryPackages = mkOption {
      type = with types; listOf package;
      default = [];
      description = "Extra packages which should be added to user env";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      lolcat
    ] ++ cfg.auxiliaryPackages;
  };
}
