{config, ...}: {
  flake.modules.nixos."gtk" = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager."gtk"];
    programs.dconf.enable = true;
    environment.systemPackages = [pkgs.gnome-themes-extra];
  };
  flake.modules.homeManager."gtk" = {pkgs, ...}: {
    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      font = {
        name = (import ./_style.nix).font;
        size = 10;
      };
      # Match the post-26.05 default; Noctalia themes GTK4 itself.
      gtk4.theme = null;
      iconTheme = {
        name = "Gruvbox-Plus-Dark";
        package = pkgs.gruvbox-plus-icons;
      };
    };
    home.packages = [pkgs.nwg-look];
  };
}
