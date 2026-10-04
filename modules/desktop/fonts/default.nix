{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      nerd-fonts.lilex
      symbola
      nerd-fonts.symbols-only
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "Lilex Nerd Font" ];
      };
    };
  };
}
