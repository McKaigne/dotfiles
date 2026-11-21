{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/50-plugins.toml".source = (pkgs.formats.toml {}).generate "50-plugins.toml" {
      "plugins" = {
        "auto_update" = "all";
        # Mod+/ uses Umbriel's built-in cheatsheet.
        "enabled" = [];
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
