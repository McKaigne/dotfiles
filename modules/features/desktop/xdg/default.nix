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
      };

      home-manager.users.${user} = {
        xdg.desktopEntries.nvim = {
          name = "Neovim";
          genericName = "Text Editor";
          comment = "Extensible modal text editor";
          exec = "ghostty -e nvim %F";
          icon = "nvim";
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

            "application/pdf" = "org.pwmt.zathura.desktop";

            "image/png" = "imv.desktop";
            "image/jpeg" = "imv.desktop";
            "image/webp" = "imv.desktop";
            "image/gif" = "imv.desktop";
            "image/svg+xml" = "imv.desktop";

            "video/mp4" = "mpv.desktop";
            "video/x-matroska" = "mpv.desktop";
            "video/webm" = "mpv.desktop";
            "video/quicktime" = "mpv.desktop";

            "audio/mpeg" = "mpv.desktop";
            "audio/flac" = "mpv.desktop";
            "audio/ogg" = "mpv.desktop";

            "text/plain" = "nvim.desktop";
            "text/markdown" = "nvim.desktop";
            "text/x-nix" = "nvim.desktop";
            "text/x-c" = "nvim.desktop";
            "text/x-c++" = "nvim.desktop";
            "text/x-python" = "nvim.desktop";
            "text/x-shellscript" = "nvim.desktop";
            "application/json" = "nvim.desktop";
            "application/toml" = "nvim.desktop";
            "application/yaml" = "nvim.desktop";
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
        wl-mirror
      ];
    };
}
