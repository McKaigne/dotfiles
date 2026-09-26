
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
      noctaliaTheme = pkgs.writeText "noctalia.toml" ''
        code_syntax_highlight = "catppuccin-mocha"
        full_screen_fg = "#d3c6aa"
        full_screen_bg = "#1e2326"
        gradient_color = ["#7fbbb3", "#a7c080"]
        directory_icon_color = "#7fbbb3"
        file_panel_fg = "#d3c6aa"
        file_panel_bg = "#1e2326"
        file_panel_border = "#3a3f5a"
        file_panel_border_active = "#7fbbb3"
        file_panel_top_directory_icon = "#7fbbb3"
        file_panel_top_path = "#83c092"
        file_panel_item_selected_fg = "#1e2326"
        file_panel_item_selected_bg = "#7fbbb3"
        sidebar_fg = "#d3c6aa"
        sidebar_bg = "#1e2326"
        sidebar_title = "#7fbbb3"
        sidebar_border = "#3a3f5a"
        sidebar_border_active = "#7fbbb3"
        sidebar_item_selected_fg = "#1e2326"
        sidebar_item_selected_bg = "#a7c080"
        sidebar_divider = "#3a3f5a"
        footer_fg = "#d3c6aa"
        footer_bg = "#1e2326"
        footer_border = "#3a3f5a"
        footer_border_active = "#7fbbb3"
        modal_fg = "#d3c6aa"
        modal_bg = "#2d353b"
        modal_border = "#7fbbb3"
        modal_border_active = "#a7c080"
        modal_cancel_fg = "#1e2326"
        modal_cancel_bg = "#e67e80"
        modal_confirm_fg = "#1e2326"
        modal_confirm_bg = "#a7c080"
        cursor = "#7fbbb3"
        correct = "#a7c080"
        error = "#e67e80"
        hint = "#dbbc7f"
        cancel = "#e67e80"
      '';

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

      superfileConfigDir = pkgs.runCommand "superfile-config-dir" {} ''
        mkdir -p $out/superfile/theme
        cp ${spfConfig} $out/superfile/config.toml
        cp ${spfHotkeys} $out/superfile/hotkeys.toml
        cp ${noctaliaTheme} $out/superfile/theme/noctalia.toml
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
            --prefix PATH : "${lib.makeBinPath [ self'.packages.helix pkgs.zoxide pkgs.bat pkgs.p7zip pkgs.unrar ]}" \
            --prefix XDG_CONFIG_DIRS : "${superfileConfigDir}" \
            --set SUPERFILE_CONFIG_DIR "${superfileConfigDir}/superfile" \
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
        meta.description = "Hermetically wrapped Superfile with frosted translucency and Noctalia theme";
      };
    };
}
