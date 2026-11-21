let
  style = import ../../../appearance/_style.nix;
in {
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/34-osd.toml".source = (pkgs.formats.toml {}).generate "34-osd.toml" {
      "osd" = {
        "background_opacity" = style.opacity;
        "orientation" = "vertical";
        "position_vertical" = "center_right";
        "kinds" = {
          "keyboard_backlight" = false;
          "keyboard_layout" = false;
          "lock_keys" = false;
          "media" = false;
          "privacy" = false;
        };
      };
    };
  };
}
