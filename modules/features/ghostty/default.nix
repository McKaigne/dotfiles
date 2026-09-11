{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty
    ];
  };
in
{
  flake.nixosModules.ghostty = nixosModule;

  perSystem = { pkgs, ... }:
    let
      ghosttyConfig = pkgs.writeText "ghostty-config" ''
        font-family = "Maple Mono NF"
        font-size = 14
        theme = noctalia
        window-decoration = false
        cursor-style = block
        cursor-style-blink = false
        cursor-color = "#ffffff"
        cursor-text = "#000000"
        custom-shader = "${./cursor_smear_fade.glsl}"
        confirm-close-surface = false
        mouse-hide-while-typing = true
      '';

      wrappedGhostty = pkgs.symlinkJoin {
        name = "ghostty";
        paths = [ pkgs.ghostty ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ghostty \
            --add-flags "--config-file=${ghosttyConfig}"
        '';
      };
    in
    {
      packages.ghostty = wrappedGhostty;

      apps.ghostty = {
        type = "app";
        program = "${wrappedGhostty}/bin/ghostty";
        meta.description = "Hermetically wrapped Ghostty terminal emulator";
      };
    };
}