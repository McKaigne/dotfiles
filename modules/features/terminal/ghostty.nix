{ self, inputs, ... }: {
  flake.nixosModules.ghostty = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [ pkgs.ghostty ];

    home-manager.users.${user} = {
      xdg.configFile."ghostty/config".text = ''
        font-family = Lilex Nerd Font
        font-size = 14

        font-feature = locl
        font-feature = cv01
        font-feature = cv09
        font-feature = cv15
        font-feature = cv03
        font-feature = cv13
        font-feature = cv11
        font-feature = ss01

        theme = noctalia
        background-opacity = 0.85
        background-blur = true
        window-decoration = false
        cursor-style = block
        shell-integration = detect
      '';
    };
  };
}
