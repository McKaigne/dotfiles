_: {
  flake.nixosModules.zsh =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };

      environment.systemPackages = [
        pkgs.zsh-abbr
      ];

      home-manager.users.${user} = {
        programs.zsh = {
          enable = true;
          enableCompletion = false;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;
          shellAliases = { };

          history = {
            size = 50000;
            save = 50000;
            path = "$HOME/.zsh_history";
            share = true;
            ignoreDups = true;
            ignoreAllDups = true;
            ignoreSpace = true;
          };

          zsh-abbr = {
            enable = true;
            abbreviations = config.workstation.shellAbbrs;
            globalAbbreviations = {
              toclip = "| wl-copy";
              fromclip = "wl-paste";
              silent = "&> /dev/null";
              noerr = "2> /dev/null";
              tojson = "| jq .";
              fromjson = "| jq .";
              ntrace = "--show-trace";
            };
          };

          initContent = ''
            export STARSHIP_CONFIG="/etc/starship.toml"
            export LS_COLORS="$(${pkgs.vivid}/bin/vivid generate catppuccin-mocha)"
            export ZSH_AUTOSUGGEST_USE_ASYNC=1
            export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
            export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

            typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

            typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[command]='fg=${config.palette.mauve},bold'
            ZSH_HIGHLIGHT_STYLES[alias]='fg=${config.palette.lavender}'
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=${config.palette.blue},bold'
            ZSH_HIGHLIGHT_STYLES[function]='fg=${config.palette.blue}'
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=${config.palette.green}'
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=${config.palette.green}'
            ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=${config.palette.green}'
            ZSH_HIGHLIGHT_STYLES[path]='fg=${config.palette.text},underline'
            ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=${config.palette.overlay0},underline'
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=${config.palette.yellow}'
            ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=${config.palette.blue}'
            ZSH_HIGHLIGHT_STYLES[command-separator]='fg=${config.palette.overlay0}'
            ZSH_HIGHLIGHT_STYLES[redirection]='fg=${config.palette.overlay0}'
            ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=${config.palette.red},bold'

            bindkey -v
            export KEYTIMEOUT=1
            autoload -z edit-command-line
            zle -N edit-command-line
            bindkey '^X^E' edit-command-line
            bindkey '^[e' edit-command-line
            bindkey '^?' backward-delete-char
            bindkey '^h' backward-delete-char
            bindkey '^w' backward-kill-word

            eval "$(${pkgs.starship}/bin/starship init zsh)"
          '';
        };
      };
    };
}
