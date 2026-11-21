let
  style = import ../appearance/_style.nix;
in {
  nixos.base = {pkgs, ...}: {
    # Temporary workaround for nanoemoji v0.16.0's retagged upstream archive.
    # Remove once the corrected hash reaches the pinned nixpkgs revision.
    nixpkgs.overlays = [
      (final: prev: {
        python313Packages = prev.python313Packages.overrideScope (
          pyFinal: pyPrev: {
            nanoemoji = pyPrev.nanoemoji.overrideAttrs (_: {
              src = prev.fetchFromGitHub {
                owner = "googlefonts";
                repo = "nanoemoji";
                tag = "v0.16.0";
                hash = "sha256-FysyKC01XBnRiur5RR9fcsTxQqE8x0JJHSoe3q6JtKc=";
              };
            });
          }
        );
      })
    ];

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
