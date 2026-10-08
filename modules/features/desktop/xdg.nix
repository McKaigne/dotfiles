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
          "inode/directory" = "org.gnome.Nautilus.desktop";
          "application/x-directory" = "org.gnome.Nautilus.desktop";
          "inode/mount-point" = "org.gnome.Nautilus.desktop";
          "x-scheme-handler/file" = "org.gnome.Nautilus.desktop";
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      nautilus
      cliphist
      satty
      hyprpicker
      wl-clipboard
    ];
  };
}
