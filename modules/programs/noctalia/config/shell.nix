{
  flake.modules.homeManager.noctalia =
    { pkgs, ... }:
    {
      xdg.configFile."noctalia/10-shell.toml".source =
        (pkgs.formats.toml { }).generate "10-shell.toml"
          {
            shell = {
              app_icon_color = "on_surface";
              avatar_path = "/etc/nixos/avatar.jpg";
              button_borders = false;
              card_borders = false;
              font_family = "Maple Mono NF";
              input_borders = false;
              launch_apps_as_systemd_services = true;
              polkit_agent = true;
              popup_borders = false;
              popup_shadows = false;
              screen_time_enabled = true;
              settings_show_advanced = true;
              settings_window_translucent = false;
              show_location = false;
              telemetry_enabled = false;
              greeter_sync.auto_sync = true;
              launcher = {
                compact = true;
                show_app_actions = true;
                width = 670;
              };
              panel = {
                borders = true;
                border_color = "primary";
                border_width = 2.0;
                transparency_mode = "solid";
                launcher_placement = "attached";
                clipboard_placement = "attached";
                control_center_placement = "floating";
                session_placement = "floating";
                wallpaper_placement = "floating";
                list_item_background = true;
                open_near_click_session = true;
                shadow = false;
              };
              screen_corners.size = 1;
              session = {
                grid = true;
                grid_columns = 1;
                actions = [
                  {
                    action = "lock";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "1";
                    variant = "default";
                  }
                  {
                    action = "logout";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "2";
                    variant = "default";
                  }
                  {
                    action = "suspend";
                    countdown_seconds = 0.0;
                    enabled = true;
                    variant = "default";
                  }
                  {
                    action = "lock_and_suspend";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "3";
                    variant = "default";
                  }
                  {
                    action = "reboot";
                    countdown_seconds = 0.0;
                    enabled = true;
                    shortcut = "4";
                    variant = "default";
                  }
                  {
                    action = "shutdown";
                    countdown_seconds = 10.0;
                    enabled = true;
                    shortcut = "5";
                    variant = "destructive";
                  }
                ];
              };
              shadow.alpha = 0.0;
              window_switcher = {
                mru = true;
                show_count = false;
              };
              clipboard_enabled = true;
            };
          };
    };
}
