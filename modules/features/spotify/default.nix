{ self, inputs, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.spotify
      pkgs.spicetify-cli
    ];
  };
in
{
  flake.nixosModules.spotify = nixosModule;

  perSystem = { self', pkgs, system, ... }:
    let
      unfreePkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      schemaDir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      fixedCursor = self'.packages.bibata-cursors-fixed;

      lucidTheme = ./themes/Lucid;
      adblockExtension = ./extensions/adblock.js;

      spotifyWrapper = pkgs.writeShellScriptBin "spotify" ''
        set -euo pipefail

        SPOTIFY_STORE="${unfreePkgs.spotify}"
        SPICETIFY="${pkgs.spicetify-cli}/bin/spicetify"
        SPICETIFY_DIR="$HOME/.local/share/spicetify"
        SPOTIFY_DIR="$SPICETIFY_DIR/spotify"
        THEMES_DIR="$HOME/.config/spicetify/Themes"
        EXTENSIONS_DIR="$HOME/.config/spicetify/Extensions"

        mkdir -p "$THEMES_DIR"
        mkdir -p "$EXTENSIONS_DIR"
        mkdir -p "$HOME/.config/spotify"
        mkdir -p "$HOME/.config/spicetify/CustomApps"
        [ -f "$HOME/.config/spotify/prefs" ] || touch "$HOME/.config/spotify/prefs"

        # 1. Sync store-backed Lucid theme and Adblockify into user config
        rm -rf "$THEMES_DIR/Lucid"
        mkdir -p "$THEMES_DIR/Lucid"
        cp -rf "${lucidTheme}/." "$THEMES_DIR/Lucid/"
        chmod -R u+w "$THEMES_DIR/Lucid"

        cp -f "${adblockExtension}" "$EXTENSIONS_DIR/adblock.js"
        chmod u+w "$EXTENSIONS_DIR/adblock.js"

        # 2. Mirror Spotify binaries from Nix store if updated
        STORE_HASH=$(basename "$SPOTIFY_STORE")
        NEED_REPATCH=0
        if [ ! -d "$SPOTIFY_DIR" ] || [ ! -f "$SPOTIFY_DIR/.store-hash" ] || [ ! -f "$SPOTIFY_DIR/.spotify-wrapped" ] || [ "$(cat "$SPOTIFY_DIR/.store-hash" 2>/dev/null)" != "$STORE_HASH" ]; then
          echo "❄ [Spicetify] Mirroring Spotify binaries..."
          rm -rf "$SPOTIFY_DIR"
          mkdir -p "$SPOTIFY_DIR"
          cp -rf "$SPOTIFY_STORE/share/spotify/." "$SPOTIFY_DIR/"
          chmod -R u+w "$SPOTIFY_DIR"
          echo "$STORE_HASH" > "$SPOTIFY_DIR/.store-hash"

          if [ -f "$SPOTIFY_DIR/spotify" ]; then
            ${pkgs.gnused}/bin/sed -i "s|$SPOTIFY_STORE/share/spotify/|$SPOTIFY_DIR/|g" "$SPOTIFY_DIR/spotify"
          fi
          NEED_REPATCH=1
        fi

        # 3. Check if Lucid or Adblockify need to be activated
        if [ ! -f "$HOME/.config/spicetify/config-xpui.ini" ]; then
          NEED_REPATCH=1
        elif ! grep -q "adblock.js" "$HOME/.config/spicetify/config-xpui.ini" 2>/dev/null; then
          NEED_REPATCH=1
        elif [ "$("$SPICETIFY" config current_theme 2>/dev/null || true)" != "Lucid" ]; then
          NEED_REPATCH=1
        fi

        if [ "$NEED_REPATCH" -eq 1 ]; then
          echo "❄ [Spicetify] Applying store-baked Lucid theme and Adblockify extension..."
          "$SPICETIFY" config \
            spotify_path "$SPOTIFY_DIR" \
            prefs_path "$HOME/.config/spotify/prefs" \
            current_theme Lucid \
            color_scheme "" \
            extensions adblock.js \
            custom_apps marketplace \
            inject_css 1 \
            inject_theme_js 1 \
            replace_colors 1 >/dev/null 2>&1 || true

          "$SPICETIFY" backup apply -n >/dev/null 2>&1 || "$SPICETIFY" apply -n >/dev/null 2>&1 || true
        else
          "$SPICETIFY" apply -n >/dev/null 2>&1 || true
        fi

        # 4. Launch Spotify on Wayland
        exec "$SPOTIFY_DIR/spotify" \
          --enable-features=UseOzonePlatform \
          --ozone-platform=wayland \
          "$@"
      '';

      wrappedSpotify = pkgs.symlinkJoin {
        name = "spotify";
        paths = [ unfreePkgs.spotify ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/spotify \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${fixedCursor}/share/icons:/run/current-system/sw/share/icons" \
            --prefix GSETTINGS_SCHEMA_DIR : "${schemaDir}" \
            --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share:${pkgs.adwaita-icon-theme}/share:${fixedCursor}/share:/run/current-system/sw/share" \
            --set-default XDG_CURRENT_DESKTOP "GNOME"

          rm -f $out/bin/spotify
          cp ${spotifyWrapper}/bin/spotify $out/bin/spotify
          chmod +x $out/bin/spotify
        '';
      };
    in
    {
      packages.spotify = wrappedSpotify;

      apps.spotify = {
        type = "app";
        program = "${wrappedSpotify}/bin/spotify";
        meta.description = "Hermetically wrapped Spotify with colocated Lucid theme and Adblockify extension";
      };
    };
}