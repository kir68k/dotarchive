{
  config,
  pkgs,
  lib,
  home-manager,
  darwin,
  ...
}:

with lib; let
  cfg = config.ki.zsh;
in {
  options.ki.zsh = {
    enable = mkEnableOption "Enable zsh with a nice config";

    # TODO make starship its own module, managed in a different way ;;
    starship = {
      enable = mkEnableOption "Enable Starship for zsh";

      settings = mkOption {
        # source: https://github.com/nix-community/home-manager/blob/5597b3a7425a9e3f41128308cb1105d3e780f633/modules/programs/starship.nix#L26
        type = with types;
          let
            prim = either bool (either int str);
            primOrPrimAttrs = either prim (attrsOf prim);
            entry = either prim (listOf primOrPrimAttrs);
            entryOrAttrsOf = t: either entry (attrsOf t);
            entries = entryOrAttrsOf (entryOrAttrsOf entry);
          in attrsOf entries // { description = "Starship configuration"; };
        default = {};
        description = "Starship configuration, see starship.rs/config for full list";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableSyntaxHighlighting = true;
      enableCompletion = true;
      completionInit = ''
        autoload -U compinit
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zmodload zsh/complist
        compinit
        _comp_options+=(globdots) # Includes hidden files
      '';
      autocd = true;
      history = {
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
        save = 10000;
        size = 10000;
        share = true;
      };
      shellAliases = {
        # Ls aliases
        ls = "ls --color=always";
        ll = "ls -l";
        lh = "ls -lh";
        la = "ls -a";
        l = "ls -lah";

        # Grep aliases
        grep = "grep --color=always";
        egrep = "grep -E";
        fgrep = "grep -F --color=always";

        # Common util aliases
        mv = "mv -v";
        rm = "rm -v";
        cp = "cp -v";
        less = "less -R"; # Allows for coloring, following ANSI escape sequences
        diff = "diff --color=always";
        diffu = "diff -u";
        ".." = "cd ..";
        oldcd = "cd $OLDPWD";
      };
      initExtra = ''
        # Enable colors
        autoload -U colors && colors
      '';
    };

    programs.dircolors = {
      enable = true;
      enableZshIntegration = true;
    };

    programs.starship = mkIf cfg.starship.enable {
      enable = true;
      enableZshIntegration = true;
      settings = cfg.starship.settings;
    };
  };
}
