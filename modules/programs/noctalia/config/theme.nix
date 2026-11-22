{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/60-theme.toml".source = (pkgs.formats.toml {}).generate "60-theme.toml" {
      "theme" = {
        "builtin" = "Kanagawa";
        "community_palette" = "Vesper";
        "mode" = "dark";
        "source" = "wallpaper";
        "wallpaper_scheme" = "m3-content";
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
            "fzf"
            "lazygit"
          ];
        };
      };
    };
  };
}
