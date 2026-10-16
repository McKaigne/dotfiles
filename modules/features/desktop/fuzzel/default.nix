{ self, inputs, ... }: {
  flake.nixosModules.fuzzel =
    { config, pkgs, ... }:
    let
      user = config.mainUser;
      p = config.palette;
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
            background=${p.hex.base}d9
            text=${p.hex.text}ff
            match=${p.hex.mauve}ff
            selection=${p.hex.surface0}ff
            selection-text=${p.hex.text}ff
            selection-match=${p.hex.mauve}ff
            border=${p.hex.mauve}ff

            [border]
            width=1
            radius=12
          '';
          force = true;
        };
      };
    };
}
