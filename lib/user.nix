# if this don't work i kms
{
  pkgs,
  home-manager,
  lib,
  system,
  overlays,
  ...
}:
with builtins; {
  mkHMUser = {
    userConfig,
    username,
  }: let 
    trySettings = tryEval (fromJSON (readFile /etc/hmsystemdata.json));
    machineData =
      if trySettings.success
      then trySettings.value
      else {};

    machineModule = {
      config,
      pkgs,
      lib,
      ...
    }: {
      options.machineData = lib.mkOption {
        description = "Settings passed from nix-darwin conf, if not present then empty";
        default = {};
      };

      config.machineData = machineData;
    };
  in
    home-manager.lib.homeManagerConfiguration rec {
      inherit pkgs;
      modules = [
        ../modules/hm
        machineModule
        {
          ki = userConfig;
          nixpkgs = {
            overlays = overlays;
            config.allowUnfree = true;
          };
          
          home = {
            inherit username;
            homeDirectory = "/Users/${username}";
            stateVersion = "22.11";
          };
        }
      ];
    };
}
