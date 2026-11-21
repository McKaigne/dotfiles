{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/50-plugins.toml".source = (pkgs.formats.toml {}).generate "50-plugins.toml" {
      "plugins" = {
        "auto_update" = "all";
        # Reads Niri's config; Umbriel uses its built-in cheatsheet instead.
        "enabled" = [
          "kenn/keybind-cheatsheet"
        ];
        "source" = [
          {
            "kind" = "git";
            "location" = "https://github.com/noctalia-dev/community-plugins";
            "name" = "community";
          }
        ];
      };
    };
  };
}
