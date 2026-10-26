{ self, inputs, ... }: {
  flake.nixosModules.zellij =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
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
            simplified_ui true
            mouse_mode true
            copy_command "wl-copy"
            copy_clipboard "primary"
            copy_on_select true

            themes {
              catppuccin-mocha {
                fg "${p.text}"
                bg "${p.base}"
                black "${p.surface0}"
                red "${p.red}"
                green "${p.green}"
                yellow "${p.yellow}"
                blue "${p.blue}"
                magenta "${p.mauve}"
                cyan "${p.teal}"
                white "${p.subtext1}"
                orange "${p.peach}"
              }
            }

            keybinds {
              normal clear-defaults=true {
                bind "Alt n" { NewPane; }
                bind "Alt h" { MoveFocus "Left"; }
                bind "Alt l" { MoveFocus "Right"; }
                bind "Alt j" { MoveFocus "Down"; }
                bind "Alt k" { MoveFocus "Up"; }
                bind "Alt [" { PreviousSwapLayout; }
                bind "Alt ]" { NextSwapLayout; }
                bind "Alt f" { ToggleFocusFullscreen; }
                bind "Alt 1" { GoToTab 1; }
                bind "Alt 2" { GoToTab 2; }
                bind "Alt 3" { GoToTab 3; }
                bind "Alt 4" { GoToTab 4; }
                bind "Alt 5" { GoToTab 5; }
              }
            }
          '';
          force = true;
        };
      };
    };
}
