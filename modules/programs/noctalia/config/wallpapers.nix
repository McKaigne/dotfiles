{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/43-wallpapers.toml".source = (pkgs.formats.toml {}).generate "43-wallpapers.toml" {
      "wallpaper" = {
        "directory" = "/etc/wallpapers";
        "transition" = [
          "melt"
        ];
        "default" = {
          "path" = "/etc/wallpapers/isekaiJoucho.jpg";
        };
        "last" = {
          "path" = "/etc/wallpapers/isekaiJoucho.jpg";
        };
        "favorite" = [
          {
            "palette_source" = "wallpaper";
            "path" = "/etc/wallpapers/wallhaven-mld9jk.jpg";
            "theme_mode" = "dark";
            "wallpaper_scheme" = "vibrant";
          }
          {
            "palette_source" = "wallpaper";
            "path" = "/etc/wallpapers/wallhaven-o5rjq9.png";
            "theme_mode" = "dark";
            "wallpaper_scheme" = "m3-monochrome";
          }
        ];
      };
    };
  };
}
