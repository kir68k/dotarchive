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
        default = {};
        description = "Settings passed from nixos system configuration. If not present will be empty";
      };

      config.machineData = machineData;
    };
  in
    home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        ../modules/users
        machineModule
        {
          ki = userConfig;
          nixpkgs = {
            overlays = overlays;
            config = {
              allowUnfree = true;
            };
          };

          home = {
            inherit username;
            stateVersion = "22.11";
            homeDirectory = "/home/${username}";
          };
          systemd.user.startServices = "sd-switch";
        }
      ];
    };

  mkSystemUser = {
    name,
    groups,
    uid,
    hashedPassword,
    shell,
    ...
  }: {
    users.users."${name}" = {
      name = name;
      isNormalUser = true;
      isSystemUser = false;
      extraGroups = groups;
      uid = uid;
      initialHashedPassword = hashedPassword;
      shell = shell;
    };
  };
}
