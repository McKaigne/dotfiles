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
        font-size = 13
        theme = Solarized Dark
        background-opacity = 0.85
        background-blur = true
        window-decoration = false
        cursor-style = block
        shell-integration = detect
      '';
    };
  };
}
