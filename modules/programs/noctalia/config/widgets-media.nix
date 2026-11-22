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
          "glyph_position" = "after";
          "peek" = true;
          "peek_delay_ms" = 350;
          "show_glyph" = false;
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
