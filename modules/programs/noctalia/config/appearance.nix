{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/12-appearance.toml".source =
        (pkgs.formats.toml { }).generate "12-appearance.toml"
          {
            backdrop = {
              enabled = false;
              blur_intensity = 0.0;
              tint_intensity = 0.0;
            };
          };
    };
}
