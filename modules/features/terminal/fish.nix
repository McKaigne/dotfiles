{ self, inputs, ... }: {
  flake.nixosModules.fish = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;
  in
  {
    programs.fish.enable = true;
    users.users.${user}.shell = pkgs.fish;

    programs.starship = {
      enable = true;
      package = pkgs.starship;
    };

    environment.sessionVariables = {
      STARSHIP_CONFIG = "/etc/starship.toml";
      SHELL = "${pkgs.fish}/bin/fish";
      EDITOR = "hx";
      VISUAL = "hx";
    };

    environment.variables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    environment.etc."starship.toml".source = ./starship.toml;

    environment.systemPackages = with pkgs; [
      fish
      starship
      zoxide
      fzf
      direnv
      eza
      bat
      fd
      ripgrep
      tree
      jq
      yazi
      btop
      wl-clipboard
    ];

    home-manager.users.${user} = {
      programs.fish = {
        enable = true;

        shellAbbrs = {
          # Clipboard
          toclip   = "wl-copy";
          fromclip = "wl-paste";

          # System Rebuilds
          rebuild  = "sudo nixos-rebuild switch --flake /etc/nixos";
          rebuildc = "sudo nixos-rebuild switch --flake /etc/nixos#castor";
          rebuildh = "sudo nixos-rebuild switch --flake /etc/nixos#hyde";
          nboot    = "sudo nixos-rebuild boot --flake /etc/nixos";
          ntest    = "sudo nixos-rebuild test --flake /etc/nixos";
          nupdate  = "nix flake update --flake /etc/nixos";
          nclean   = "nix-collect-garbage -d";
          ntry     = "nix run nixpkgs#";
          nshell   = "nix shell nixpkgs#";

          # Git
          ga       = "git add -A";
          gstage   = "git add -A";
          gpatch   = "git add -p";
          gundo    = "git reset --soft HEAD~1";
          gunstage = "git restore --staged .";
          gwipe    = "git reset --hard HEAD";
          gamend   = "git commit --amend --no-edit";
          gst      = "git status";
          gc       = "git commit -m";
          gdiff    = "git diff";
          gdiffs   = "git diff --staged";
          gp       = "git push";
          gpushf   = "git push --force-with-lease";
          gpl      = "git pull";
          glg      = "git log --oneline --graph -n 20";
          gbranch  = "git switch";
          gnew     = "git switch -c";

          # Noctalia IPC
          nlaunch   = "noctalia msg panel-toggle launcher";
          ncontrol  = "noctalia msg panel-toggle control-center";
          nsession  = "noctalia msg panel-toggle session";
          nclip     = "noctalia msg panel-toggle clipboard";
          nsettings = "noctalia msg settings-toggle";
          nbar      = "noctalia msg bar-toggle";
          nlock     = "noctalia msg session lock";
          nclosemsg = "noctalia msg notification-clear-active";

          # Niri IPC
          nreload = "niri msg action load-config-file";
          nclose  = "niri msg action close-window";
          nquit   = "niri msg action quit";
          nfocus  = "niri msg action focus-window --id";
          nwins   = "niri msg -j windows";
          nwork   = "niri msg -j workspaces";
          nmon    = "niri msg -j outputs";

          # Tmux
          t      = "tmux";
          ta     = "tmux attach -t";
          tls    = "tmux ls";
          tkill  = "tmux kill-session -t";
          tkilla = "tmux kill-server";

          # Zoxide
          zq  = "zoxide query";
          zql = "zoxide query -l";
          za  = "zoxide add";
          zr  = "zoxide remove";

          # Editors & Files
          v   = "hx";
          vi  = "hx";
          vim = "hx";
          em  = "emacsclient -c -a ''";

          hxf = "hx /etc/nixos/flake.nix";
          hxh = "hx /etc/nixos/modules/hosts/hyde/default.nix";
          hxc = "hx /etc/nixos/modules/shared/core.nix";
          hxi = "hx /etc/nixos/modules/features/desktop/config.kdl";
          hxt = "hx /etc/nixos/modules/features/terminal/tmux.nix";
        };

        shellAliases = {
          l      = "ls";
          ll     = "ls -l";
          la     = "ls -a";
          bottom = "btop";
          btm    = "btop";
          y      = "yazi";
          g      = "git";
          lg     = "lazygit";
          music  = "cliamp";
          amp    = "cliamp";
        };

        functions = {
          starship_transient_prompt_func = ''
            starship module character
          '';

          fkill = ''
            set -l selected (ps -eo pid,user,comm,%cpu,%mem | fzf --header="Select process to kill (ESC to cancel)")
            if test -n "$selected"
              set -l target_pid (string split " " (string trim $selected))[1]
              kill -9 $target_pid
              echo "Killed process $target_pid"
            end
          '';

          cft = ''
            set -l target "."
            if test (count $argv) -ge 1
              set target $argv[1]
            end
            set -l extensions -e nix -e kdl -e toml -e conf -e ini -e el -e json -e nu -e fish -e py -e css -e lua
            set -l excludes -E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log"
            set -l files (fd . (path resolve $target) -t f -L -H -S -50k $extensions $excludes)
            if test (count $files) -eq 0
              echo "No configuration files found in $target"
              return
            end
            set -l tree_out (printf "%s\n" $files | tree -a -F --fromfile)
            echo "$tree_out" | wl-copy
            echo "$tree_out"
            echo "\n[Copied tree of "(count $files)" core config files to clipboard]"
          '';

          cfb = ''
            set -l target "."
            if test (count $argv) -ge 1
              set target $argv[1]
            end
            set -l extensions -e nix -e kdl -e toml -e conf -e ini -e el -e json -e nu -e fish -e py -e css -e lua
            set -l excludes -E .git -E flake.lock -E node_modules -E target -E result -E "*cache*" -E "*Cache*" -E "*.log"
            set -l files (fd . (path resolve $target) -t f -L -H -S -50k $extensions $excludes)
            if test (count $files) -eq 0
              echo "No configuration files found in $target"
              return
            end
            set -l content (for f in $files; bat --style=header,grid --paging=never $f; end)
            printf "%s\n" $content | wl-copy
            echo "[Copied full content of "(count $files)" config files to clipboard]"
          '';
        };

        interactiveShellInit = ''
          set -g fish_greeting ""
          starship init fish | source
          zoxide init fish | source
          direnv hook fish | source
        '';
      };
    };
  };
}
