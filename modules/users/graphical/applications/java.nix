{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.ki.graphical.applications.java;
in {
  options.ki.graphical.applications.java = {
    enable = mkEnableOption "Enable Java";

    pkg = mkOption {
      type = types.package;
      default = pkgs.jdk11;
      description = "Package to use for the JDK";
    };

    ## I can't find a good way to override the JDK pkg and don't want to write a standalone wakefield pkg
    ## This will be commented out until there's a solution somewhere
    #  wakefield = {
    #    enable = mkOption {
    #      type = types.bool;
    #      default =
    #        if config.ki.graphical.wayland == true
    #        then true
    #        else false;
    #      description = "Use wakefield instead of normal JDK";
    #    };
    #  };
  };

  config = mkIf (cfg.enable) {
    programs.java = {
      enable = true;
      package = cfg.pkg;
    };
  };
}
