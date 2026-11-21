{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/33-notifications.toml".source =
        (pkgs.formats.toml { }).generate "33-notifications.toml"
          {
            notification = {
              filter_order = [ ];
              history_retention_hours = 1;
            };
          };
    };
}
