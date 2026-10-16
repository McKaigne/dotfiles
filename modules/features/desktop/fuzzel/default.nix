{ self, inputs, ... }: {
  flake.nixosModules.fuzzel =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
    in
    {
      environment.systemPackages = [ pkgs.fuzzel ];

      home-manager.users.${user} = {
        xdg.configFile."fuzzel/fuzzel.ini" = {
          text = ''
            [main]
            font=Lilex Nerd Font:size=14
            prompt="➜ "
            lines=12
            width=35
            horizontal-pad=20
            vertical-pad=15
            inner-pad=10
            prefer-no-csd

            [colors]
            background=1e1e2ed9
            text=cdd6f4ff
            match=cba6f7ff
            selection=313244ff
            selection-text=cdd6f4ff
            selection-match=cba6f7ff
            border=cba6f7ff

            [border]
            width=1
            radius=12
          '';
          force = true;
        };
      };
    };
}
