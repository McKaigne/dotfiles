{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/60-theme.toml".source = (pkgs.formats.toml {}).generate "60-theme.toml" {
      # Which palette is active (source, builtin, community palette, wallpaper
      # scheme) is picked in Noctalia's settings and saved to gui.toml; Nix
      # only owns the mode and the templates.
      "theme" = {
        "mode" = "dark";
        "templates" = {
          "builtin_ids" = [
            "btop"
            "cava"
            "emacs"
            "gtk3"
            "gtk4"
            "kcolorscheme"
            "foot"
            "qt"
            "umbriel"
          ];
          "community_ids" = [
            "pywalfox"
            "bat"
          ];
        };
      };
    };
  };
}
