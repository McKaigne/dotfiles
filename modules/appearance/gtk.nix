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
  }: {
    # Noctalia owns gtk.css (it imports noctalia.css). Append the glass import
    # after it so its translucent backgrounds win; never rewrite the file.
    home.activation.gtkGlassImport = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        for dir in gtk-3.0 gtk-4.0; do
          css=${lib.escapeShellArg config.xdg.configHome}/$dir/gtk.css
          mkdir -p "$(dirname "$css")"
          [ -f "$css" ] || echo '@import url("noctalia.css");' > "$css"
          grep -q 'glass.css' "$css" || echo '@import url("glass.css");' >> "$css"
        done
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
