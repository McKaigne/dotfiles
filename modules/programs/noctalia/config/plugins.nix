{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/50-plugins.toml".source =
        (pkgs.formats.toml { }).generate "50-plugins.toml"
          {
            plugins = {
              auto_update = "all";
              enabled = [
                "noctalia/bitwarden"
                "kenn/keybind-cheatsheet"
                "8bury/lid-guard"
                "ayagmar/obs-control"
                "h-jangra/keyviz"
              ];
              source = [
                {
                  kind = "git";
                  location = "https://github.com/noctalia-dev/official-plugins";
                  name = "official";
                }
                {
                  kind = "git";
                  location = "https://github.com/noctalia-dev/community-plugins";
                  name = "community";
                }
              ];
            };
            plugin_settings."noctalia/bitwarden".gen_special = true;
          };
    };
}
