let
  style = import ../../../appearance/_style.nix;
in {
  flake.modules.homeManager."noctalia" = {pkgs, ...}: {
    xdg.configFile."noctalia/33-notifications.toml".source = (pkgs.formats.toml {}).generate "33-notifications.toml" {
      "notification" = {
        "background_opacity" = style.opacity;
        "filter_order" = [];
        "history_retention_hours" = 1;
      };
    };
  };
}
