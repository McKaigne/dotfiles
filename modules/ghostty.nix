
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
        theme = catppuccin-mocha
        window-decoration = false

        cursor-style = block
        cursor-style-blink = false
        cursor-color = "#cba6f7"
        cursor-text = "#11111b"
        adjust-cursor-thickness = 2

        confirm-close-surface = false
        mouse-hide-while-typing = true

        # Splits
        keybind = ctrl+shift+e=new_split:down
        keybind = ctrl+shift+o=new_split:right

        # Split Navigation
        keybind = ctrl+alt+left=goto_split:left
        keybind = ctrl+alt+right=goto_split:right
        keybind = ctrl+alt+up=goto_split:top
        keybind = ctrl+alt+down=goto_split:bottom
        keybind = ctrl+alt+h=goto_split:left
        keybind = ctrl+alt+l=goto_split:right
        keybind = ctrl+alt+k=goto_split:top
        keybind = ctrl+alt+j=goto_split:bottom

        # Tabs
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
        meta.description = "Ghostty terminal emulator with Catppuccin Mocha styling";
      };
    };
}
