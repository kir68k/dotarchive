{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.zsh;
in {
  options.ki.zsh = {
    enable = mkEnableOption "Enable Z Shell with a nice config";
  };

  config = mkIf (cfg.enable) (
    let
      # Remove home directory from XDG
      dotDir = builtins.substring ((builtins.stringLength config.home.homeDirectory) + 1) (builtins.stringLength config.xdg.configHome) config.xdg.configHome;
    in {
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
          _comp_options+=(globdots) # Include hidden files.
        '';
        autocd = true;
        dotDir = "${dotDir}/zsh";
        history = {
          extended = true;
          ignoreDups = true;
          ignoreSpace = true;
          save = 10000;
          size = 10000;
          share = true;
          path = "${config.xdg.dataHome}/zsh/zhist";
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
          egrep = "grep -E --color=always";
          fgrep = "grep -F --color=always";

          # Util aliases
          mv = "mv -v";
          rm = "rm -v";
          cp = "cp -v";
          less = "less -R"; # Enables colored less output, so e.g `diff -u --color=always foo.c bar.c | less -R` lets `less` use ANSI escape sequences which `diff --color=always` uses, `-r` would allow for more characters, but less standarization. `man 1 less` for more.
          diff = "diff --color=always";
          diffu = "diff -u";
          ".." = "cd ..";
          oldcd = "cd $OLDPWD";
        };
        initExtra = ''
          # Enable colors and change prompt:
          autoload -U colors && colors
          PS1="
          %B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}㉿%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
        '';
      };
    }
  );
}
