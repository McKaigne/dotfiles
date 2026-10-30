_: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.zellij ];

      home-manager.users.${user} = {
        programs.zellij = {
          enable = true;
        };

        xdg.configFile."zellij/config.kdl" = {
          text = ''
            theme "catppuccin-mocha"
            default_layout "compact"
            pane_frames false
            default_shell "fish"
            copy_on_select true
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
            copy_clipboard "system"
            mouse_mode true
            scroll_buffer_size 100000
            session_serialization true
            attach_to_session true

            themes {
              catppuccin-mocha {
                bg "#585b70"
                fg "#cdd6f4"
                red "#f38ba8"
                green "#a6e3a1"
                blue "#89b4fa"
                yellow "#f9e2af"
                magenta "#cba6f7"
                orange "#fab387"
                cyan "#89dceb"
                black "#181825"
                white "#cdd6f4"
              }
            }

            ui {
              pane_frames {
                rounded_corners true
              }
            }
          '';
          force = true;
        };
      };
    };
}
