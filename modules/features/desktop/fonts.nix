{ self, inputs, ... }: {
  flake.nixosModules.fonts = { pkgs, ... }: {
    fonts = {
      packages = with pkgs; [
        nerd-fonts.lilex
      ];
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "Lilex Nerd Font" ];
        };
      };
    };
  };
}
