{
  flake.modules.homeManager.desktop-niri = {
    programs.niri.settings = {
      window-rules = [
        {
          matches = [
            { app-id = "^(com\\.bitwarden\\.desktop|[Bb]itwarden)$"; }
            { title = ".*(Private Browsing|Incognito).*"; }
          ];
          block-out-from = "screencast";
        }
        {
          matches = [ { } ];
          geometry-corner-radius = {
            top-left = 4.0;
            top-right = 4.0;
            bottom-left = 4.0;
            bottom-right = 4.0;
          };
          clip-to-geometry = true;
          draw-border-with-background = false;
        }
        {
          matches = [ { title = "^Zellij Session Manager$"; } ];
          open-floating = true;
          default-column-width.proportion = 0.55;
          default-window-height.proportion = 0.65;
        }
        {
          matches = [
            { app-id = "^dev\\.noctalia\\.Noctalia.*$"; }
            { app-id = "^org\\.freedesktop\\.impl\\.portal\\.desktop.*$"; }
            { app-id = "^xdg-desktop-portal.*$"; }
            { title = "^Open File.*$"; }
            { title = "^Save File.*$"; }
            { title = "^Save As.*$"; }
            { title = "^File Upload.*$"; }
            { title = "^(Picture-in-Picture|Picture in picture)$"; }
            { app-id = "^pavucontrol$"; }
            { app-id = "^com\\.saivert\\.pwvucontrol$"; }
            { app-id = "^easyeffects$"; }
            { app-id = "^com\\.gabm\\.satty$"; }
            { app-id = "^xarchiver$"; }
            { app-id = "^blueman-manager$"; }
          ];
          open-floating = true;
        }
      ];

      layer-rules = [
        {
          matches = [ { namespace = "^noctalia-attached-panel.*bitwarden.*$"; } ];
          block-out-from = "screencast";
        }
        {
          matches = [ { namespace = "^noctalia-backdrop$"; } ];
          place-within-backdrop = true;
        }
      ];
    };
  };
}
