{
  system,
  pkgs,
  lib,
  inputs,
  utils,
  darwin,
}:
with builtins;
with utils; {
  mkHost = {
    name,
    systemConfig,
    cpuCores,
    stateVersion,
  }: let
    enable = ["enable"];
    moduleFolder = "/modules/darwin/";

    systemEnableModule = enableModule systemConfig;

    userCfg = {
      inherit name systemConfig cpuCores;
    };
  in
    darwin.lib.darwinSystem {
      inherit system;
      inherit inputs;

      modules = [
        {
          imports = [(import ../modules/darwin {inherit inputs;})];

          ki = systemConfig;
          environment.etc."hmsystemdata.json".text = toJSON userCfg;

          nix.settings = {
            max-jobs = lib.mkDefault cpuCores;
            experimental-features = [ "nix-command" "flakes" ];
          };
          programs.zsh.enable = lib.mkDefault true;
          services.nix-daemon.enable = lib.mkDefault true;
          system.stateVersion = stateVersion;
        }
      ];
    };
}
