
{ self, ... }:
let
  nixosModule = { config, pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.superfile
    ];
  };
in
{
  flake.nixosModules.superfile = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      spfConfig = pkgs.writeText "config.toml" ''
        theme = "noctalia"
        style = "noctalia"
        editor = "hx"
        dir_editor = "hx"
        auto_check_update = false
        cd_on_quit = true
        default_open_file_preview = true
        default_directory = "."
        nerdfont = true
        transparent_background = true
        file_preview_width = 0
        sidebar_width = 20
        zoxide_support = true
      '';

      spfHotkeys = pkgs.writeText "hotkeys.toml" ''
        confirm = ["enter", "l"]
        parent_directory = ["h", "backspace"]
        quit = ["q", "esc"]
        list_up = ["k", "up"]
        list_down = ["j", "down"]
        page_up = ["ctrl+u", "pgup"]
        page_down = ["ctrl+d", "pgdown"]
        create_new_file_panel = ["n", ""]
        close_file_panel = ["w", ""]
        open_zoxide = ["z", ""]
        search_bar = ["/", ""]
      '';

      superfileDesktop = pkgs.makeDesktopItem {
        name = "superfile";
        desktopName = "Superfile";
        comment = "Terminal File Manager with Noctalia Theme";
        icon = "system-file-manager";
        exec = "${self'.packages.ghostty}/bin/ghostty --class=ghostty.superfile --title=Superfile -e superfile %u";
        terminal = false;
        categories = [ "System" "FileManager" ];
        mimeTypes = [ "inode/directory" "application/x-directory" ];
      };

      wrappedSuperfile = pkgs.symlinkJoin {
        name = "superfile";
        paths = [ pkgs.superfile superfileDesktop ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/superfile \
            --prefix PATH : "${lib.makeBinPath [ self'.packages.helix pkgs.zoxide pkgs.bat pkgs.p7zip pkgs.unrar pkgs.jq pkgs.coreutils ]}" \
            --run '
              SPF_DIR="$HOME/.config/superfile"
              mkdir -p "$SPF_DIR/theme"

              # Seed base config and hotkeys if missing
              [ -f "$SPF_DIR/config.toml" ] || cp "${spfConfig}" "$SPF_DIR/config.toml"
              [ -f "$SPF_DIR/hotkeys.toml" ] || cp "${spfHotkeys}" "$SPF_DIR/hotkeys.toml"

              # Dynamically generate superfile theme from Noctalia active palette
              COLORS_JSON="$HOME/.config/noctalia/colors.json"
              if [ -f "$COLORS_JSON" ]; then
                PRI=$(${pkgs.jq}/bin/jq -r '\'' .mPrimary // "#7fbbb3" '\'' "$COLORS_JSON")
                SEC=$(${pkgs.jq}/bin/jq -r '\'' .mSecondary // "#a7c080" '\'' "$COLORS_JSON")
                TER=$(${pkgs.jq}/bin/jq -r '\'' .mTertiary // "#83c092" '\'' "$COLORS_JSON")
                ERR=$(${pkgs.jq}/bin/jq -r '\'' .mError // "#e67e80" '\'' "$COLORS_JSON")
                SURF=$(${pkgs.jq}/bin/jq -r '\'' .mSurface // "#1e2326" '\'' "$COLORS_JSON")
                SURF_VAR=$(${pkgs.jq}/bin/jq -r '\'' .mSurfaceVariant // "#2d353b" '\'' "$COLORS_JSON")
                TXT=$(${pkgs.jq}/bin/jq -r '\'' .mOnSurface // "#d3c6aa" '\'' "$COLORS_JSON")
                OUTLINE=$(${pkgs.jq}/bin/jq -r '\'' .mOutline // "#3a3f5a" '\'' "$COLORS_JSON")
              else
                PRI="#7fbbb3"; SEC="#a7c080"; TER="#83c092"; ERR="#e67e80"
                SURF="#1e2326"; SURF_VAR="#2d353b"; TXT="#d3c6aa"; OUTLINE="#3a3f5a"
              fi

              cat << EOF > "$SPF_DIR/theme/noctalia.toml"
code_syntax_highlight = "catppuccin-mocha"
full_screen_fg = "$TXT"
full_screen_bg = "$SURF"
gradient_color = ["$PRI", "$SEC"]
directory_icon_color = "$PRI"
file_panel_fg = "$TXT"
file_panel_bg = "$SURF"
file_panel_border = "$OUTLINE"
file_panel_border_active = "$PRI"
file_panel_top_directory_icon = "$PRI"
file_panel_top_path = "$TER"
file_panel_item_selected_fg = "$SURF"
file_panel_item_selected_bg = "$PRI"
sidebar_fg = "$TXT"
sidebar_bg = "$SURF"
sidebar_title = "$PRI"
sidebar_border = "$OUTLINE"
sidebar_border_active = "$PRI"
sidebar_item_selected_fg = "$SURF"
sidebar_item_selected_bg = "$SEC"
sidebar_divider = "$OUTLINE"
footer_fg = "$TXT"
footer_bg = "$SURF"
footer_border = "$OUTLINE"
footer_border_active = "$PRI"
modal_fg = "$TXT"
modal_bg = "$SURF_VAR"
modal_border = "$PRI"
modal_border_active = "$SEC"
modal_cancel_fg = "$SURF"
modal_cancel_bg = "$ERR"
modal_confirm_fg = "$SURF"
modal_confirm_bg = "$SEC"
cursor = "$PRI"
correct = "$SEC"
error = "$ERR"
hint = "$SEC"
cancel = "$ERR"
EOF
            ' \
            --set EDITOR "hx" \
            --set VISUAL "hx"
          [ -e $out/bin/spf ] || ln -sf $out/bin/superfile $out/bin/spf
        '';
      };
    in
    {
      packages.superfile = wrappedSuperfile;

      apps.superfile = {
        type = "app";
        program = "${wrappedSuperfile}/bin/superfile";
        meta.description = "Hermetically wrapped Superfile dynamically themed by Noctalia palette";
      };
    };
}
