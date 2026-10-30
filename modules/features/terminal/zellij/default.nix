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
            simplified_ui true
            default_shell "fish"
            mouse_mode true
            pane_frames true
            copy_on_select true
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
            copy_clipboard "system"
            session_serialization true

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
