{
  flake.modules.homeManager."fish" = {pkgs, ...}: {
    programs.fish = {
      shellAbbrs = {
        ncd = "cd /etc/nixos";
        rnix = "repomix /etc/nixos";
        rcfg = "repomix ~/.config";
        nupdate = "nix flake update --flake /etc/nixos";
        nclean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";

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

        nreload = "umbriel msg config-reload";
        nclose = "umbriel msg window-close";
        nquit = "umbriel msg session-quit";
        nfocus = "umbriel msg window-focus";
        nwins = "umbriel msg windows";
        nwork = "umbriel msg workspaces";
        nmon = "umbriel msg outputs";

        zj = "zellij";
        zja = "zellij attach";
        zjls = "zellij list-sessions";
        zjkill = "zellij kill-session";
        zjkilla = "zellij kill-all-sessions";

        zq = "zoxide query";
        zql = "zoxide query -l";
        za = "zoxide add";
        zr = "zoxide remove";

        h = "hx";
        v = "hx";
        vi = "hx";
        vim = "hx";
        nv = "hx";
        bottom = "btop";
        btm = "btop";
        n = "nnn";
        g = "git";
        lg = "lazygit";

        hxf = "hx /etc/nixos/flake.nix";
        hxh = "hx /etc/nixos/modules/hosts/hyde/default.nix";
        hxc = "hx /etc/nixos/modules/system/environment.nix";
        hxfish = "hx /etc/nixos/modules/programs/fish/default.nix";
        hxi = "hx /etc/nixos/modules/desktops/umbriel/keybinds.nix";
        hxz = "hx /etc/nixos/modules/programs/zellij.nix";
      };

      interactiveShellInit = ''
        abbr --add ntrace --position anywhere -- --show-trace

        # fzf colors from the Noctalia fzf template.
        if test -r ~/.config/fzf/themes/noctalia.fish
          source ~/.config/fzf/themes/noctalia.fish
        end
      '';

      functions = {
        fkill = {
          description = "Interactively select and kill a process";
          body = ''
            set -l selected (ps -eo pid,user,comm,%cpu,%mem | ${pkgs.fzf}/bin/fzf --header="Select process to kill (ESC to cancel)")
            if test -n "$selected"
              set -l targetPid (echo "$selected" | ${pkgs.gawk}/bin/awk '{print $1}')
              kill -9 "$targetPid"; and echo "Killed process $targetPid"
            end
          '';
        };

        clast = {
          description = "Re-run last command and copy its output to clipboard";
          body = ''
            set -l cmd (history --max 1)
            if test -n "$cmd"
              eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
              and echo "Copied output of '$cmd' to clipboard."
            end
          '';
        };

        chist = {
          description = "Interactively select a historical command and copy its output";
          body = ''
            set -l cmd (history | ${pkgs.fzf}/bin/fzf --reverse --header="Select command to copy output to clipboard:")
            if test -n "$cmd"
              eval "$cmd" | ${pkgs.wl-clipboard}/bin/wl-copy
              and echo "Copied output of '$cmd' to clipboard."
            end
          '';
        };
      };
    };
  };
}
