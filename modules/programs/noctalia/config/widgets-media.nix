{
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/36-widgets-media.toml".source = (pkgs.formats.toml {}).generate "36-widgets-media.toml" {
      "widget" = {
        "input_volume" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
        "media" = {
          "show_glyph" = false;
          "hide_when_no_media" = true;
          "max_length" = 180;
          "title_scroll" = "on_hover";
        };
        "volume" = {
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
        };
      };
    };
  };
}
