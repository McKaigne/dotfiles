{ self, inputs, ... }: {
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
            copy_on_select true

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
