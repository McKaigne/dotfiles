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
            pane_frames false
            simplified_ui true
            default_shell "fish"
            default_layout "default"
            copy_on_select true
            copy_command "${pkgs.wl-clipboard}/bin/wl-copy"
            copy_clipboard "system"
            mouse_mode true
            scroll_buffer_size 100000
            session_serialization true
            attach_to_session true
            auto_layout true

            ui {
              pane_frames {
                rounded_corners false
              }
            }
          '';
          force = true;
        };
      };
    };
}
