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

      adblockExtension = ./extensions/adblock.js;

      marketplaceColorIni = pkgs.writeText "color.ini" ''
        [marketplace]
        text               = FFFFFF
        subtext            = DEDEDE
        main               = 121212
        sidebar            = 121212
        player             = 121212
        card               = 181818
        shadow             = 000000
        selected-row       = 2A2A2A
        button             = 1DB954
        button-active      = 1ED760
        button-disabled    = 535353
        tab-active         = 282828
        notification       = 1DB954
        notification-error = E22134
        misc               = FFFFFF
      '';

      spotifyWrapper = pkgs.writeShellScriptBin "spotify" ''
        set -euo pipefail

        SPOTIFY_STORE="${unfreePkgs.spotify}"
        SPICETIFY="${pkgs.spicetify-cli}/bin/spicetify"
        SPICETIFY_DIR="$HOME/.local/share/spicetify"
        SPOTIFY_DIR="$SPICETIFY_DIR/spotify"
        THEMES_DIR="$HOME/.config/spicetify/Themes"
        EXTENSIONS_DIR="$HOME/.config/spicetify/Extensions"
        MARKETPLACE_DIR="$HOME/.config/spicetify/CustomApps/marketplace"

        mkdir -p "$THEMES_DIR/marketplace"
        mkdir -p "$EXTENSIONS_DIR"
        mkdir -p "$HOME/.config/spotify"
        mkdir -p "$HOME/.config/spicetify/CustomApps"
        [ -f "$HOME/.config/spotify/prefs" ] || touch "$HOME/.config/spotify/prefs"

        # 1. Sync store-backed Adblockify extension and Marketplace placeholder
        cp -f "${adblockExtension}" "$EXTENSIONS_DIR/adblock.js"
        chmod u+w "$EXTENSIONS_DIR/adblock.js"

        if [ ! -f "$THEMES_DIR/marketplace/color.ini" ]; then
          cp "${marketplaceColorIni}" "$THEMES_DIR/marketplace/color.ini"
          chmod u+w "$THEMES_DIR/marketplace/color.ini"
        fi

        # 2. Bootstrap Marketplace app if missing
        if [ ! -f "$MARKETPLACE_DIR/manifest.json" ]; then
          echo "❄ [Spicetify] Installing Marketplace custom app..."
          mkdir -p "$MARKETPLACE_DIR"
          TMP_ZIP=$(mktemp /tmp/marketplace-XXXXXX.zip)
          TMP_DIR=$(mktemp -d /tmp/marketplace-XXXXXX)
          if ${pkgs.curl}/bin/curl -fsSL "https://github.com/spicetify/marketplace/releases/latest/download/marketplace.zip" -o "$TMP_ZIP" 2>/dev/null; then
            ${pkgs.unzip}/bin/unzip -q -o "$TMP_ZIP" -d "$TMP_DIR" 2>/dev/null || true
            if [ -f "$TMP_DIR/manifest.json" ]; then
              cp -rf "$TMP_DIR/"* "$MARKETPLACE_DIR/"
            else
              SUBDIR=$(find "$TMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)
              if [ -n "$SUBDIR" ]; then
                cp -rf "$SUBDIR/"* "$MARKETPLACE_DIR/"
              fi
            fi
            echo "❄ [Spicetify] Marketplace installed."
          fi
          rm -rf "$TMP_ZIP" "$TMP_DIR"
        fi

        # 3. Mirror Spotify binaries from Nix store if updated
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

        # 4. Enforce Marketplace theme engine and Adblockify extension
        if [ ! -f "$HOME/.config/spicetify/config-xpui.ini" ] || [ "$("$SPICETIFY" config current_theme 2>/dev/null || true)" != "marketplace" ] || ! grep -q "adblock.js" "$HOME/.config/spicetify/config-xpui.ini" 2>/dev/null; then
          NEED_REPATCH=1
        fi

        if [ "$NEED_REPATCH" -eq 1 ]; then
          echo "❄ [Spicetify] Configuring Marketplace theme engine and Adblockify..."
          "$SPICETIFY" config \
            spotify_path "$SPOTIFY_DIR" \
            prefs_path "$HOME/.config/spotify/prefs" \
            current_theme marketplace \
            color_scheme marketplace \
            extensions adblock.js \
            custom_apps marketplace \
            inject_css 1 \
            inject_theme_js 1 \
            replace_colors 1 >/dev/null 2>&1 || true

          "$SPICETIFY" backup apply -n >/dev/null 2>&1 || "$SPICETIFY" apply -n >/dev/null 2>&1 || true
        fi

        # 5. Launch Spotify on Wayland
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
        meta.description = "Hermetically wrapped Spotify with Spicetify Marketplace and Adblockify extension";
      };
    };
}