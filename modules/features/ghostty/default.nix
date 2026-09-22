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
        adjust-cursor-thickness = 3
        custom-shader = "${./cursor_smear_fade.glsl}"
        custom-shader-animation = true
        confirm-close-surface = false
        mouse-hide-while-typing = true

        # Splits
        keybind = ctrl+shift+e=new_split:down
        keybind = ctrl+shift+o=new_split:right

        # Split Navigation (Arrows + HJKL)
        keybind = ctrl+alt+left=goto_split:left
        keybind = ctrl+alt+right=goto_split:right
        keybind = ctrl+alt+up=goto_split:top
        keybind = ctrl+alt+down=goto_split:bottom
        keybind = ctrl+alt+h=goto_split:left
        keybind = ctrl+alt+l=goto_split:right
        keybind = ctrl+alt+k=goto_split:top
        keybind = ctrl+alt+j=goto_split:bottom

        # Resize splits (10 lines) (Arrows + HJKL)
        keybind = super+ctrl+shift+left=resize_split:left,10
        keybind = super+ctrl+shift+right=resize_split:right,10
        keybind = super+ctrl+shift+up=resize_split:up,10
        keybind = super+ctrl+shift+down=resize_split:down,10
        keybind = super+ctrl+shift+h=resize_split:left,10
        keybind = super+ctrl+shift+l=resize_split:right,10
        keybind = super+ctrl+shift+k=resize_split:up,10
        keybind = super+ctrl+shift+j=resize_split:down,10

        # Tabs (Arrows + HJKL)
        keybind = ctrl+shift+t=new_tab
        keybind = ctrl+shift+left=previous_tab
        keybind = ctrl+shift+right=next_tab
        keybind = ctrl+shift+h=previous_tab
        keybind = ctrl+shift+l=next_tab
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