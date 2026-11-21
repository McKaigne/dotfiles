{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/43-wallpapers.toml".source =
        (pkgs.formats.toml { }).generate "43-wallpapers.toml"
          {
            wallpaper = {
              directory = "/etc/wallpapers";
              fill_mode = "crop";
              transition_duration = 300;
              default.path = "/etc/wallpapers/isekaiJoucho.jpg";
              last.path = "/etc/wallpapers/isekaiJoucho.jpg";
            };
          };
    };
}
