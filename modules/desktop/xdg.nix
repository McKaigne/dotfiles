{ config, pkgs, ... }:
let
  user = config.mainUser;
in
{
  programs.dconf.enable = true;
  services.gvfs.enable = true;

  environment.etc."xdg/direnv/direnv.toml".text = ''
    [whitelist]
    prefix = [
      "/home/${user}/Projects",
      "/home/${user}/projects"
    ]
  '';

  xdg.mime = {
    enable = true;
    defaultApplications = {
      "inode/directory" = "org.gnome.Nautilus.desktop";
      "application/x-directory" = "org.gnome.Nautilus.desktop";
      "inode/mount-point" = "org.gnome.Nautilus.desktop";
      "x-scheme-handler/file" = "org.gnome.Nautilus.desktop";
    };
  };

  environment.systemPackages = with pkgs; [
    nautilus
    cliphist
    satty
    hyprpicker
    wl-clipboard
  ];
}
