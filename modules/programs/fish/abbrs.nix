{
  flake.modules.homeManager."fish" = {pkgs, ...}: {
    programs.fish = {
      shellAbbrs = {
        ncd = "z /etc/nixos";
        # Rebuild (git add first: flakes ignore files git doesn't track).
        # nrc builds castor's system here on hyde and activates it there;
        # nrh, from castor, builds and activates hyde on hyde.
        nr = "git -C /etc/nixos add -A && nh os switch";
        ntest = "git -C /etc/nixos add -A && nh os test";
        nboot = "git -C /etc/nixos add -A && nh os boot";
        nrc = "git -C /etc/nixos add -A && nh os switch --hostname castor --target-host root@castor";
        nrh = "git -C /etc/nixos add -A && nh os switch --hostname hyde --build-host root@hyde --target-host root@hyde";
        # A package without installing it; the cursor lands after nixpkgs#.
        ntry = {
          expansion = "nix run nixpkgs#%";
          setCursor = true;
        };
        nshell = {
          expansion = "nix shell nixpkgs#%";
          setCursor = true;
        };
        rnix = "repomix /etc/nixos";
        rcfg = "repomix ~/.config";
        nupdate = "nix flake update --flake /etc/nixos";
        nclean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
        nsearch = "nh search";

        # Emacs: open in a new frame without tying up the terminal.
        e = "emacsclient -n";
        erestart = "systemctl --user restart emacs";

        # CMake, the way your projects build (build/, Ninja). cmb configures
        # and builds in one go: with Ninja the build type is set when
        # configuring, and re-configuring an unchanged build/ is instant.
        # Edit Release to Debug when you need a debug build.
        cmb = "cmake -B build -G Ninja -DCMAKE_BUILD_TYPE=Release && cmake --build build";
        cmt = "ctest --test-dir build --output-on-failure";

        # Services and logs.
        scu = "systemctl --user";
        jfu = "journalctl --user -f -u";
        jf = "journalctl -f -u";

        # Clipboard: paste into a file, or (anywhere on the line) pipe into
        # the clipboard, a pager or a search.
        wp = "wl-paste >";
        C = {
          position = "anywhere";
          expansion = "| wl-copy";
        };
        L = {
          position = "anywhere";
          expansion = "| less";
        };
        G = {
          position = "anywhere";
          expansion = "| rg";
        };
        mkd = "mkdir -p";

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

        zq = "zoxide query";
        zql = "zoxide query -l";
        za = "zoxide add";
        zr = "zoxide remove";

        l = "ls -alh";
        ll = "ls -l";
        bottom = "btop";
        btm = "btop";
        n = "nnn";
        g = "git";
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
