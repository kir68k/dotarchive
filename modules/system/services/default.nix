{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./monero
    #./nginx
  ];
}
