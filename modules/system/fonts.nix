let
  style = import ../appearance/_style.nix;
in {
  nixos.base = {pkgs, ...}: {
    fonts.packages = with pkgs; [
      jetbrains-mono
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
      noto-fonts-cjk-sans
      maple-mono.NF
    ];

    # Maple Mono for every generic family, so apps without their own font follow it.
    fonts.fontconfig.defaultFonts = {
      sansSerif = [style.font "Noto Sans"];
      serif = [style.font "Noto Serif"];
      monospace = [style.font];
      emoji = ["Noto Color Emoji"];
    };
  };
}
