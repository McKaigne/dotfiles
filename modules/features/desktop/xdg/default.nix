_: {
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
        config = {
          common.default = [ "gtk" ];
          niri = {
            default = [ "gnome" "gtk" ];
            "org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];
          };
        };
      };

      home-manager.users.${user} = {
        xdg.desktopEntries.helix = {
          name = "Helix";
          genericName = "Text Editor";
          comment = "Modal text editor";
          exec = "footclient -e hx %F";
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

            "text/plain" = "helix.desktop";
            "text/markdown" = "helix.desktop";
            "text/x-nix" = "helix.desktop";
            "text/x-c" = "helix.desktop";
            "text/x-c++" = "helix.desktop";
            "text/x-python" = "helix.desktop";
            "text/x-shellscript" = "helix.desktop";
            "application/json" = "helix.desktop";
            "application/toml" = "helix.desktop";
            "application/yaml" = "helix.desktop";
          };
        };

        xdg.configFile."pcmanfm/default/pcmanfm.conf" = {
          text = ''
            [config]
            bm_open_method=0
            terminal=footclient

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
