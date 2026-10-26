{ self, inputs, ... }: {
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

      environment.systemPackages = with pkgs; [
        zsh
        zsh-abbr
        fzf
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
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
            export LS_COLORS="$(${pkgs.vivid}/bin/vivid generate catppuccin-mocha)"
            export ZSH_AUTOSUGGEST_USE_ASYNC=1
            export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
            export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

            typeset -ga ZSH_HIGHLIGHT_HIGHLIGHTERS=(main)

            typeset -A ZSH_HIGHLIGHT_STYLES
            ZSH_HIGHLIGHT_STYLES[command]='fg=#cba6f7,bold'
            ZSH_HIGHLIGHT_STYLES[alias]='fg=#b4befe'
            ZSH_HIGHLIGHT_STYLES[builtin]='fg=#89b4fa,bold'
            ZSH_HIGHLIGHT_STYLES[function]='fg=#89b4fa'
            ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#a6e3a1'
            ZSH_HIGHLIGHT_STYLES[path]='fg=#cdd6f4,underline'
            ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#6c7086,underline'
            ZSH_HIGHLIGHT_STYLES[globbing]='fg=#f9e2af'
            ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#89b4fa'
            ZSH_HIGHLIGHT_STYLES[command-separator]='fg=#6c7086'
            ZSH_HIGHLIGHT_STYLES[redirection]='fg=#6c7086'
            ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f38ba8,bold'

            bindkey -e
          '';
        };
      };
    };
}
