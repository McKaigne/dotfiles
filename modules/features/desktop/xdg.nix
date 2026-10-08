{ self, inputs, ... }: {
  flake.nixosModules.xdg = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    programs.dconf.enable = true;
    services.gvfs.enable = true;

    home-manager.users.${user} = {
      xdg.mimeApps = {
        enable = true;
        defaultApplications = {
          "inode/directory" = "pcmanfm.desktop";
          "application/x-directory" = "pcmanfm.desktop";
          "inode/mount-point" = "pcmanfm.desktop";
          "x-scheme-handler/file" = "pcmanfm.desktop";
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
        };
      };

      xdg.configFile."pcmanfm/default/pcmanfm.conf".text = ''
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
        show_hidden=0
        sort_type=0
        sort_by=0
      '';
    };

    environment.systemPackages = with pkgs; [
      pcmanfm
      xarchiver
      libfm
      lxmenu-data
      shared-mime-info
      cliphist
      satty
      hyprpicker
      wl-clipboard
    ];
  };
}
