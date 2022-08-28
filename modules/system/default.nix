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
    ./ipfs
    ./laptop
    ./network
    ./relativity
    ./rrStack
    ./security
    ./services
    #./secrets
    #./ssh
    ./tor
    ./tty
    ./virtualisation
  ];
}
