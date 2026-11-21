{ lib, ... }:
{
  options.workstation = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "pollux";
      description = "Primary workstation user account.";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Networking hostname.";
    };

    stateVersion = lib.mkOption {
      type = lib.types.str;
      default = "25.05";
      description = "NixOS / Home Manager stateVersion.";
    };

    system = lib.mkOption {
      type = lib.types.str;
      default = "x86_64-linux";
      description = "Nixpkgs host system.";
    };

    isDesktopCompute = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether host enables desktop compute/studio modules.";
    };

    display = {
      output = lib.mkOption {
        type = lib.types.str;
        default = "DP-1";
        description = "Primary display connector identifier.";
      };

      mode = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Display resolution and refresh rate string.";
      };

      scale = lib.mkOption {
        type = lib.types.str;
        default = "1.0";
        description = "Display output scaling factor.";
      };

      xftDpi = lib.mkOption {
        type = lib.types.str;
        default = "96";
        description = "Xft DPI value.";
      };
    };

    shellAbbrs = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      description = "Unified Fish abbreviation mappings.";
      default = {
        f = "tv";
        television = "tv";

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

        nreload = "niri msg action load-config-file";
        nclose = "niri msg action close-window";
        nquit = "niri msg action quit";
        nfocus = "niri msg action focus-window --id";
        nwins = "niri msg -j windows";
        nwork = "niri msg -j workspaces";
        nmon = "niri msg -j outputs";

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
        hxi = "hx /etc/nixos/modules/desktops/niri/keybinds.nix";
        hxz = "hx /etc/nixos/modules/programs/zellij.nix";
      };
    };
  };
}
