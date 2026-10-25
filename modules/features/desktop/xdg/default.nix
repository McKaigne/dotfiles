{ self, inputs, ... }: {
  flake.nixosModules.xdg =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      programs.dconf.enable = true;
      services.gvfs.enable = true;

      xdg.portal = {
        enable = true;
        extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
        config.niri = {
          default = [ "gnome" "gtk" ];
          "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
        };
      };

      home-manager.users.${user} = {
        xdg.desktopEntries.Helix = {
          name = "Helix";
          genericName = "Text Editor";
          comment = "Modal terminal text editor";
          exec = "ghostty -e hx %F";
          icon = "helix";
          terminal = false;
          categories = [ "Utility" "TextEditor" "Development" ];
          mimeType = [
            "text/plain"
            "text/markdown"
            "text/x-nix"
            "text/x-c"
            "text/x-c++"
            "text/x-python"
            "text/x-shellscript"
            "application/json"
            "application/toml"
            "application/yaml"
          ];
        };

        xdg.desktopEntries.learnharness = {
          name = "LearnHarness";
          genericName = "AI Learning Agent Harness";
          comment = "Agent harness for learning difficult domains with Socratic guidance and knowledge graphs";
          exec = "learnharness %U";
          icon = "system-help";
          terminal = false;
          categories = [ "Education" "Development" "Utility" ];
          mimeType = [ "text/markdown" "application/x-markdown" ];
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "inode/directory" = "pcmanfm.desktop";
            "application/x-directory" = "pcmanfm.desktop";
            "inode/mount-point" = "pcmanfm.desktop";
            "x-scheme-handler/file" = "pcmanfm.desktop";
            "text/html" = "librewolf.desktop";
            "x-scheme-handler/http" = "librewolf.desktop";
            "x-scheme-handler/https" = "librewolf.desktop";

            "image/png" = "imv.desktop";
            "image/jpeg" = "imv.desktop";
            "image/webp" = "imv.desktop";
            "image/gif" = "imv.desktop";
            "image/svg+xml" = "imv.desktop";

            "text/plain" = "Helix.desktop";
            "text/markdown" = "Helix.desktop";
            "text/x-nix" = "Helix.desktop";
            "text/x-c" = "Helix.desktop";
            "text/x-c++" = "Helix.desktop";
            "text/x-python" = "Helix.desktop";
            "text/x-shellscript" = "Helix.desktop";
            "application/json" = "Helix.desktop";
            "application/toml" = "Helix.desktop";
            "application/yaml" = "Helix.desktop";
          };
        };

        xdg.configFile."pcmanfm/default/pcmanfm.conf" = {
          text = ''
            [config]
            bm_open_method=0
            terminal=ghostty

            [volume]
            mount_on_removable=1
            mount_removable=1
            autorun=1

            [ui]
            always_show_tabs=0
            max_tab_chars=32
            win_width=900
            win_height=600
            splitter_pos=180
            side_pane_mode=places
            view_mode=detailed
            show_hidden=1
            show_statusbar=0
            sort_type=0
            sort_by=0
          '';
          force = true;
        };
      };

      environment.systemPackages = with pkgs; [
        pcmanfm
        xarchiver
        libfm
        lxmenu-data
        shared-mime-info
        cliphist
        satty
        wl-clipboard
      ];
    };
}
