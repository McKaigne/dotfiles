{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs; # VERY IMPORTANT

      settings = {
        input = {
          touchpad = {
            tap = _: { };
            natural-scroll = _: { };
            scroll-method = "two-finger";
          };
        };

        gestures = {
          dnd-edge-view-scroll = {
            trigger-width = 30;
          };
          dnd-edge-workspace-switch = {
            trigger-height = 50;
          };
        };

        binds = {
          "Mod+D".spawn = [ "noctalia" "toggle" "launcher" ];
          "Mod+Return".spawn = [ "ghostty" ];
          "Mod+Q".close-window = _: { };
          "Mod+Tab".toggle-overview = _: { };
        };
      };
    };
  };
}
