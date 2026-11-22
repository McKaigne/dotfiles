{config, ...}: {
  flake.modules.nixos."gtk" = {pkgs, ...}: {
    home-manager.sharedModules = [config.flake.modules.homeManager."gtk"];
    programs.dconf.enable = true;
    environment.systemPackages = [pkgs.gnome-themes-extra];
  };
  flake.modules.homeManager."gtk" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    glassLast = pkgs.writeShellApplication {
      name = "gtk-glass-last";
      runtimeInputs = [pkgs.gnugrep pkgs.coreutils];
      text = builtins.readFile ./_gtk-glass-last.sh;
    };
  in {
    # Noctalia owns gtk.css (it imports noctalia.css); keep the glass import
    # after it so its translucent backgrounds win. Noctalia's theme hook runs
    # the same script (see noctalia/config/templates.nix).
    home.activation.gtkGlassImport = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        ${lib.getExe glassLast}
      fi
    '';

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
