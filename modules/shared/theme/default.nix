_: {
  flake.nixosModules.palette =
    { lib, pkgs, ... }:
    let
      raw = {
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
      };
    in
    {
      options.palette = lib.mkOption {
        type = lib.types.attrs;
        description = "Centralized Catppuccin Mocha color palette";
        default = raw // {
          hex = lib.mapAttrs (_: lib.removePrefix "#") raw;
        };
      };

      options.theme = {
        fonts = {
          sans = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Cozette";
            };
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.cozette;
            };
            size = lib.mkOption {
              type = lib.types.int;
              default = 13;
            };
          };
          mono = {
            name = lib.mkOption {
              type = lib.types.str;
              default = "Cozette";
            };
            package = lib.mkOption {
              type = lib.types.package;
              default = pkgs.cozette;
            };
            size = lib.mkOption {
              type = lib.types.int;
              default = 13;
            };
          };
        };
        cursor = {
          name = lib.mkOption {
            type = lib.types.str;
            default = "Bibata-Modern-Classic";
          };
          size = lib.mkOption {
            type = lib.types.int;
            default = 16;
          };
        };
        opacity = lib.mkOption {
          type = lib.types.str;
          default = "0.85";
        };
        radius = lib.mkOption {
          type = lib.types.int;
          default = 0;
        };
        borderWidth = lib.mkOption {
          type = lib.types.int;
          default = 3;
        };
        gap = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };
      };
    };
}
