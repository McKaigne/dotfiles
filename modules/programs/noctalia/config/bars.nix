{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/30-bars.toml".source =
        (pkgs.formats.toml { }).generate "30-bars.toml"
          {
            bar = {
              order = [ "fancy" ];
              fancy = {
                enabled = true;
                background_opacity = 1.0;
                capsule_opacity = 1.0;
                shadow = false;
                font_family = "Maple Mono NF";
                hover_highlight = false;
                margin_ends = 0;
                radius_top_left = 0;
                radius_top_right = 0;
                widget_spacing = 8;
                start = [
                  "workspaces"
                ];
                center = [
                  "notifications"
                  "clock"
                  "media"
                ];
                end = [
                  "tray"
                  "volume"
                  "input_volume"
                  "brightness"
                  "session"
                ];
              };
            };
          };
    };
}
