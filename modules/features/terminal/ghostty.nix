{ self, inputs, ... }: {
  flake.nixosModules.ghostty = { config, pkgs, ... }:
  let
    user = config.mainUser;
  in
  {
    environment.systemPackages = [ pkgs.ghostty ];

    home-manager.users.${user} = {
      # Seed initial Noctalia theme with Solarized Osaka
      xdg.configFile."ghostty/themes/noctalia".text = ''
        palette = 0=#073642
        palette = 1=#dc322f
        palette = 2=#859900
        palette = 3=#b58900
        palette = 4=#268bd2
        palette = 5=#d33682
        palette = 6=#2aa198
        palette = 7=#eee8d5
        palette = 8=#002b36
        palette = 9=#cb4b16
        palette = 10=#586e75
        palette = 11=#657b83
        palette = 12=#839496
        palette = 13=#6c71c4
        palette = 14=#93a1a1
        palette = 15=#fdf6e3
        background = #002b36
        foreground = #839496
        cursor-color = #2aa198
        cursor-text = #002b36
        selection-background = #073642
        selection-foreground = #93a1a1
      '';

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
