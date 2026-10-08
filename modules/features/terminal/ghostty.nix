{ self, inputs, ... }: {
  flake.nixosModules.ghostty = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [ pkgs.ghostty ];

    home-manager.users.${user} = {
      # No hardcoded palettes. Ghostty strictly consumes Noctalia's dynamic theme file.
      xdg.configFile."ghostty/config".text = ''
        font-family = Lilex Nerd Font
        font-size = 13
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
