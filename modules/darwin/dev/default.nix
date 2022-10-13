{
  config,
  pkgs,
  lib,
  darwin,
  ...
}:

with lib; let
  cfg = config.ki.dev;
in {
  options.ki.dev = {
    enable = mkEnableOption "Enable (software) development oriented options/modules";

    # Options for specific languages, #TODO add more later
    languages = {
      haskell.enable = mkEnableOption "Add e.g. Haskell related packages to env";
    };   
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = with pkgs; [
      git direnv #sysTools
    ] ++ (
      if (cfg.languages.haskell.enable)
      then [ghc haskell-language-server hlint cabal-install]
      else []
    );
  };
}
