{ self, inputs, ... }: {
  flake.nixosModules.zsh =
    {
      config,
      pkgs,
      lib,
      ...
    }:
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
        zoxide
        fzf
      ];

      home-manager.users.${user} = {
        programs.zsh = {
          enable = true;
          enableCompletion = false;
          autosuggestion.enable = true;
          syntaxHighlighting.enable = true;

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
            abbreviations = {
              rebuild = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
              rebuildc = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#castor";
              rebuildh = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos#hyde";
              nr = "git -C /etc/nixos add -A && sudo nixos-rebuild switch --flake /etc/nixos";
              nboot = "git -C /etc/nixos add -A && sudo nixos-rebuild boot --flake /etc/nixos";
              ntest = "git -C /etc/nixos add -A && sudo nixos-rebuild test --flake /etc/nixos";
              ncd = "cd /etc/nixos";
              nupdate = "nix flake update --flake /etc/nixos";
              nclean = "nix-collect-garbage -d";
              ntry = "nix run nixpkgs#";
              nshell = "nix shell nixpkgs#";
              ntrace = "--show-trace";

              ga = "git add -A";
              gstage = "git add -A";
              gpatch = "git add -p";
              gundo = "git reset --soft HEAD~1";
              gunstage = "git restore --staged .";
              gwipe = "git reset --hard HEAD";
              gamend = "git commit --amend --no-edit";
              gst = "git status";
              gc = "git commit -m";
              gdiff = "git diff";
              gdiffs = "git diff --staged";
              gp = "git push";
              gpushf = "git push --force-with-lease";
              gpl = "git pull";
              glg = "git log --oneline --graph -n 20";
              gbranch = "git switch";
              gnew = "git switch -c";

              nlaunch = "noctalia msg panel-toggle launcher";
              ncontrol = "noctalia msg panel-toggle control-center";
              nsession = "noctalia msg panel-toggle session";
              nclip = "noctalia msg panel-toggle clipboard";
              nsettings = "noctalia msg settings-toggle";
              nbar = "noctalia msg bar-toggle";
              nlock = "noctalia msg session lock";
              nclosemsg = "noctalia msg notification-clear-active";

              nreload = "niri msg action load-config-file";
              nclose = "niri msg action close-window";
              nquit = "niri msg action quit";
              nfocus = "niri msg action focus-window --id";
              nwins = "niri msg -j windows";
              nwork = "niri msg -j workspaces";
              nmon = "niri msg -j outputs";

              t = "tmux";
              ta = "tmux attach -t";
              tls = "tmux ls";
              tkill = "tmux kill-session -t";
              tkilla = "tmux kill-server";

              l = "ls";
              ll = "ls -l";
              la = "ls -a";
              zq = "zoxide query";
              zql = "zoxide query -l";
              za = "zoxide add";
              zr = "zoxide remove";

              v = "hx";
              vi = "hx";
              vim = "hx";
              bottom = "btop";
              btm = "btop";
              y = "yazi";
              g = "git";
              lg = "lazygit";
              fetch = "fetch";

              hxf = "hx /etc/nixos/flake.nix";
              hxh = "hx /etc/nixos/modules/hosts/hyde/default.nix";
              hxc = "hx /etc/nixos/modules/shared/core/default.nix";
              hxfish = "hx /etc/nixos/modules/features/terminal/fish/default.nix";
              hxz = "hx /etc/nixos/modules/features/terminal/zsh/default.nix";
              hxi = "hx /etc/nixos/modules/features/desktop/niri/niri.kdl";
              hxt = "hx /etc/nixos/modules/features/terminal/tmux/default.nix";
            };
            globalAbbreviations = {
              toclip = "| wl-copy";
              fromclip = "wl-paste";
              silent = "&> /dev/null";
              noerr = "2> /dev/null";
              tojson = "| jq .";
              fromjson = "| jq .";
            };
          };

          initContent = ''
            export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
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

            export FZF_DEFAULT_OPTS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

            eval "$(${pkgs.zoxide}/bin/zoxide init zsh)"
            eval "$(${pkgs.direnv}/bin/direnv hook zsh)"

            bindkey -e
          '';
        };
      };
    };
}
