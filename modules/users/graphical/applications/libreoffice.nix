{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.graphical.applications;
in {
  options.ki.graphical.applications.libreoffice = {
    enable = mkEnableOption "Enable LibreOffice configured";
  };

  config = mkIf (cfg.libreoffice.enable) {
    home.packages = with pkgs; [
      libreoffice
      languagetool
    ];

    home.sessionVariables = {
      DICPATH = "${config.xdg.dataHome}/dictionary/hunspell:${config.xdg.dataHome}/dictionary/hyphen";
    };

    home.activation = {
      dictionaryLinker = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p ${config.xdg.dataHome}/dictionary
        $DRY_RUN_CMD ln -sfn ${pkgs.hunspellDicts.da_DK}/share/hunspell ${config.xdg.dataHome}/dictionary/hunspell
        $DRY_RUN_CMD ln -sfn ${pkgs.hunspellDicts.da_DK}/share/myspell ${config.xdg.dataHome}/dictionary/myspell
        $DRY_RUN_CMD ln -sfn ${pkgs.hyphen}/share/hyphen ${config.xdg.dataHome}/dictionary/hyphen
      '';
    };
  };
}
