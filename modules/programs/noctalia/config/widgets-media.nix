{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/36-widgets-media.toml".source =
        (pkgs.formats.toml { }).generate "36-widgets-media.toml"
          {
            widget = {
              input_volume.enabled = true;
              media = {
                hide_album_art = true;
                hide_when_no_media = true;
                title_scroll = "on_hover";
              };
              volume.enabled = true;
              volume_input_minimal = {
                device = "input";
                type = "volume";
              };
              volume_minimal = {
                font_family = "GaramontoCode Nerd Font";
                type = "volume";
              };
            };
          };
    };
}
