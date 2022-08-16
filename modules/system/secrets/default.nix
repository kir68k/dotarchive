{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.secrets;
in {
  options.ki.secrets.identityPaths = mkOption {
    type = with types; listOf str;
    description = "The path to age identities (private key)";
  };

  config = {
    age.identityPaths = cfg.identityPaths;
  };
}
