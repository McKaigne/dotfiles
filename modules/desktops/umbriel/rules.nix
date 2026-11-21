{
  flake.modules.homeManager."desktop-umbriel" = {
    programs.umbriel.settings = {
      layer_rule = [
        {
          match.namespace = ''^noctalia-(bar-[^"]+|notification|dock|panel|attached-panel|osd|desktop-widget-[^"]*)$'';
          blur = true;
          blur_ignore_alpha = 0.5;
          blur_popups = true;
        }
      ];

      window_rule = [
        {
          match.app_id = "^(com\\.bitwarden\\.desktop|[Bb]itwarden)$";
          block_capture = true;
        }
        {
          match.title = ".*(Private Browsing|Incognito).*";
          block_capture = true;
        }
        {
          match.app_id = "^helium$";
          default_maximize = true;
        }
        {
          match.title = "^(Picture-in-Picture|Picture in picture)$";
          default_floating = true;
          default_maximize = false;
          default_position = {
            x = 20;
            y = 20;
            anchor = "bottom_right";
          };
        }
        {
          match.app_id = "^dev\\.noctalia\\.Noctalia$";
          default_floating = true;
          default_floating_size_px = {
            width = 1020;
            height = 900;
          };
        }
        {
          match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
          default_floating = true;
          default_floating_size_px = {
            width = 800;
            height = 600;
          };
        }
        {
          match.app_id = "^(pavucontrol|com\\.saivert\\.pwvucontrol|easyeffects|com\\.gabm\\.satty|xarchiver|blueman-manager)$";
          default_floating = true;
        }
      ];
    };
  };
}
