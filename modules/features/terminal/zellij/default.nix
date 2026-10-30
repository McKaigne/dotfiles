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
              locked {
                bind "Ctrl g" { SwitchToMode "Normal"; }
                bind "Alt h" "Alt Left" { MoveFocus "Left"; }
                bind "Alt l" "Alt Right" { MoveFocus "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }
              }
            }
            default_mode "locked"
            default_layout "compact"
            default_layout "compact"
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

            ui {
              pane_frames {
                rounded_corners true
                hide_session_name true
                hide_session_name true
              }
            }
          '';
          force = true;
        };
      };
    };
}
