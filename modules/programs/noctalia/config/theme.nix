{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/60-theme.toml".source = (pkgs.formats.toml {}).generate "60-theme.toml" {
      "theme" = {
        "builtin" = "Gruvbox";
        "community_palette" = "Everforest";
        "custom_palette" = "verdant-nocturne";
        "mode" = "dark";
        "source" = "custom";
        "wallpaper_scheme" = "vibrant";
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
            "chromium-based"
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
