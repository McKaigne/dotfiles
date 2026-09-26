
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
      # Fallback theme if ~/.config/ghostty/themes/noctalia is not yet seeded
      fallbackTheme = pkgs.runCommand "ghostty-fallback-theme" {} ''
        mkdir -p $out/share/ghostty/themes
        cat << 'EOF' > $out/share/ghostty/themes/noctalia
background = 1e1e2e
foreground = cdd6f4
cursor-color = cba6f7
cursor-text = 11111b
selection-background = 313244
selection-foreground = cdd6f4
palette = 0=#1e1e2e
palette = 1=#f38ba8
palette = 2=#a6e3a1
palette = 3=#f9e2af
palette = 4=#89b4fa
palette = 5=#f5c2e7
palette = 6=#94e2d5
palette = 7=#cdd6f4
palette = 8=#45475a
palette = 9=#f38ba8
palette = 10=#a6e3a1
palette = 11=#f9e2af
palette = 12=#89b4fa
palette = 13=#f5c2e7
palette = 14=#94e2d5
palette = 15=#cdd6f4
EOF
      '';

      # Notice: NO cursor-color override here!
      # The cursor color is controlled by the active Noctalia theme file.
      ghosttyConfig = pkgs.writeText "ghostty-config" ''
font-family = "Maple Mono NF"
font-size = 14
theme = noctalia
window-decoration = false
background-opacity = 0.88

cursor-style = block
cursor-style-blink = false
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
        paths = [ pkgs.ghostty fallbackTheme ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/ghostty \
            --run '
              # Seed user theme directory with fallback if missing
              if [ ! -f "$HOME/.config/ghostty/themes/noctalia" ]; then
                mkdir -p "$HOME/.config/ghostty/themes"
                cp "${fallbackTheme}/share/ghostty/themes/noctalia" "$HOME/.config/ghostty/themes/noctalia" 2>/dev/null || true
              fi
            ' \
            --prefix XDG_DATA_DIRS : "${fallbackTheme}/share" \
            --add-flags "--config-file=${ghosttyConfig}"
        '';
      };
    in
    {
      packages.ghostty = wrappedGhostty;

      apps.ghostty = {
        type = "app";
        program = "${wrappedGhostty}/bin/ghostty";
        meta.description = "Hermetically wrapped Ghostty connected to Noctalia dynamic theme";
      };
    };
}
