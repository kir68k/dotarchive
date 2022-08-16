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
    (import ./core { inherit inputs; })
    ./gnome
    ./graphical
    ./greetd
    ./laptop
    ./network
    ./relativity
    #./secrets
    #./ssh
    ./tty
    ./virtualisation
  ];
}
