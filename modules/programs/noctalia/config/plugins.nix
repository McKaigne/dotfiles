{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/50-plugins.toml".source =
        (pkgs.formats.toml { }).generate "50-plugins.toml"
          {
            plugins = {
              auto_update = "none";
              enabled = [ ];
              source = [ ];
            };
          };
    };
}
