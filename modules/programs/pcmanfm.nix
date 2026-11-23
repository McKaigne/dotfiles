{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.pcmanfm = {pkgs, ...}: {
    home-manager.sharedModules = [flakeConfig.flake.modules.homeManager.pcmanfm];
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

  flake.modules.homeManager.pcmanfm = {
    xdg.desktopEntries.helix = {
      name = "Helix";
      genericName = "Text Editor";
      comment = "Modal text editor";
      exec = "foot -e hx %F";
      icon = "helix";
      terminal = false;
      categories = [
        "Utility"
        "TextEditor"
        "Development"
      ];
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

        "text/plain" = "emacs.desktop";
        "text/markdown" = "emacs.desktop";
        "text/x-nix" = "emacs.desktop";
        "text/x-c" = "emacs.desktop";
        "text/x-c++" = "emacs.desktop";
        "text/x-python" = "emacs.desktop";
        "text/x-shellscript" = "emacs.desktop";
        # The standard names (the three above are not what file managers report).
        "text/x-csrc" = "emacs.desktop";
        "text/x-chdr" = "emacs.desktop";
        "text/x-c++src" = "emacs.desktop";
        "text/x-c++hdr" = "emacs.desktop";
        "application/x-shellscript" = "emacs.desktop";
        "text/x-cmake" = "emacs.desktop";
        "text/x-makefile" = "emacs.desktop";
        "text/x-log" = "emacs.desktop";
        "text/x-org" = "emacs.desktop";
        "text/csv" = "emacs.desktop";
        "application/xml" = "emacs.desktop";
        "application/json" = "emacs.desktop";
        "application/toml" = "emacs.desktop";
        "application/yaml" = "emacs.desktop";
      };
    };

    xdg.configFile."pcmanfm/default/pcmanfm.conf" = {
      text = ''
        [config]
        bm_open_method=0
        terminal=foot

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
        side_pane_mode=dirtree
        view_mode=detailed
        show_hidden=1
        show_statusbar=0
        sort_type=0
        sort_by=0
      '';
      force = true;
    };
  };
}
