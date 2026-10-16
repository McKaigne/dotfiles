{ self, inputs, ... }: {
  flake.nixosModules.palette =
    { lib, ... }:
    {
      options.palette = lib.mkOption {
        type = lib.types.attrs;
        description = "Centralized Catppuccin Mocha color palette";
        default = {
          # Core Surfaces & Text
          base = "#1e1e2e";
          mantle = "#181825";
          crust = "#11111b";
          text = "#cdd6f4";
          subtext1 = "#bac2de";
          subtext0 = "#a6adc8";
          overlay2 = "#9399b2";
          overlay1 = "#7f849c";
          overlay0 = "#6c7086";
          surface2 = "#585b70";
          surface1 = "#45475a";
          surface0 = "#313244";

          # Accents
          lavender = "#b4befe";
          blue = "#89b4fa";
          sapphire = "#74c7ec";
          sky = "#89dceb";
          teal = "#94e2d5";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          peach = "#fab387";
          maroon = "#eba0ac";
          red = "#f38ba8";
          mauve = "#cba6f7";
          pink = "#f5c2e7";
          flamingo = "#f2cdcd";
          rosewater = "#f5e0dc";

          # Hex without '#' for apps requiring raw hex (Fuzzel, etc.)
          hex = {
            base = "1e1e2e";
            mantle = "181825";
            crust = "11111b";
            text = "cdd6f4";
            mauve = "cba6f7";
            surface0 = "313244";
            surface1 = "45475a";
            surface2 = "585b70";
            red = "f38ba8";
            green = "a6e3a1";
            peach = "fab387";
            teal = "94e2d5";
            blue = "89b4fa";
            lavender = "b4befe";
          };
        };
      };
    };
}
