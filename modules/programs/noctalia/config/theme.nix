{
  flake.modules.homeManager."noctalia" = {
    config,
    lib,
    pkgs,
    ...
  }: {
    xdg.configFile."noctalia/60-theme.toml".source = (pkgs.formats.toml {}).generate "60-theme.toml" {
      "theme" = {
        "builtin" = "Gruvbox";
        "community_palette" = "Everforest";
        "custom_palette" = "verdant-nocturne";
        "mode" = "dark";
        "source" = "custom";
        "wallpaper_scheme" = "vibrant";
        "templates" = {
          "builtin_ids" =
            [
              "btop"
              "cava"
              "emacs"
              "gtk3"
              "gtk4"
              "kcolorscheme"
              "foot"
              "qt"
              "umbriel"
            ]
            # The niri template fails without a niri config.kdl, so only enable it there.
            ++ lib.optional (config.workstation.desktop == "niri") "niri";
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
