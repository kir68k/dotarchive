{
  config,
  pkgs,
  lib,
  ...
}: {
  users.users.nixos = {
    name = "nixos";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    uid = 1000;
    initialPassword = "hewwonyan";
    shell = pkgs.zsh;
  };
}
