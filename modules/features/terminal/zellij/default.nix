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
                text_unselected {
                  base 205 214 244
                  background 30 30 46
                }
                text_selected {
                  base 24 24 37
                  background 203 166 247
                }
                ribbon_unselected {
                  base 205 214 244
                  background 49 50 68
                }
                ribbon_selected {
                  base 24 24 37
                  background 203 166 247
                }
                table_title {
                  base 203 166 247
                  background 30 30 46
                }
                table_cell_unselected {
                  base 205 214 244
                  background 30 30 46
                }
                table_cell_selected {
                  base 24 24 37
                  background 137 180 250
                }

                fg "#cdd6f4"
                bg "#1e1e2e"
                black "#181825"
                red "#f38ba8"
                green "#a6e3a1"
                yellow "#f9e2af"
                blue "#89b4fa"
                magenta "#cba6f7"
                orange "#fab387"
                cyan "#89dceb"
                white "#cba6f7"
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
