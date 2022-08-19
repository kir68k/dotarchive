{inputs}: {
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./applications
    ./boot
    ./connectivity
    (import ./core {inherit inputs;})
    ./gnome
    ./graphical
    ./greetd
    ./laptop
    ./network
    ./relativity
    ./security
    #./secrets
    #./ssh
    ./tty
    ./virtualisation
  ];
}
