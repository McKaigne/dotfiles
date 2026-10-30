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
            keybinds preset="unlock-first" {
              shared_except "locked" {
                bind "Alt h" "Alt Left" { MoveFocus "Left"; }
                bind "Alt l" "Alt Right" { MoveFocus "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }
              }
            }
            default_mode "locked"
            pane_frames true
            simplified_ui true
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
                bg "#181825"
                fg "#cdd6f4"
                red "#f38ba8"
                green "#a6e3a1"
                blue "#89b4fa"
                yellow "#f9e2af"
                magenta "#cba6f7"
                orange "#fab387"
                cyan "#89dceb"
                black "#1e1e2e"
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
