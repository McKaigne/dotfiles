{ self, ... }:
let
  nixosModule = { config, pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.superfile
    ];

    systemd.tmpfiles.rules = [
      "d /home/${config.mainUser}/.local/share/superfile 0755 ${config.mainUser} users -"
      "f+ /home/${config.mainUser}/.local/share/superfile/toggleDotFile 0644 ${config.mainUser} users - true"
      "f+ /home/${config.mainUser}/.local/share/superfile/firstUseCheck 0644 ${config.mainUser} users - true"
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
        editor = "${self'.packages.helix}/bin/hx"
        dir_editor = "${self'.packages.helix}/bin/hx"

        auto_check_update = false
        cd_on_quit = true
        default_open_file_preview = true
        default_directory = "."

        file_size_use_si = false
        default_sort_type = 0
        sort_order_reversed = false
        case_sensitive_sort = false

        nerdfont = true
        transparent_background = false
        file_preview_width = 0
        sidebar_width = 20
        show_panel_footer_info = true

        border_top = "─"
        border_bottom = "─"
        border_left = "│"
        border_right = "│"
        border_top_left = "╭"
        border_top_right = "╮"
        border_bottom_left = "╰"
        border_bottom_right = "╯"
        border_middle_left = "├"
        border_middle_right = "┤"

        metadata = true
        enable_md5_checksum = false
        zoxide_support = true
      '';

      spfHotkeys = pkgs.writeText "hotkeys.toml" ''
        confirm = ["enter", "l"]
        parent_directory = ["h", "backspace"]
        quit = ["q", "esc"]
        cd_quit = ["Q", ""]

        list_up = ["k", "up"]
        list_down = ["j", "down"]
        page_up = ["ctrl+u", "pgup"]
        page_down = ["ctrl+d", "pgdown"]

        create_new_file_panel = ["n", ""]
        close_file_panel = ["w", ""]
        next_file_panel = ["tab", "L"]
        previous_file_panel = ["shift+tab", "H"]
        toggle_file_preview_panel = ["f", ""]
        open_sort_options_menu = ["o", ""]
        toggle_reverse_sort = ["R", ""]

        focus_on_sidebar = ["s", ""]
        focus_on_process_bar = ["p", ""]
        focus_on_metadata = ["m", ""]

        copy_items = ["y", "ctrl+c"]
        cut_items = ["x", "ctrl+x"]
        paste_items = ["p", "ctrl+v"]
        delete_items = ["d", "ctrl+d"]
        file_panel_item_rename = ["r", "ctrl+r"]
        file_panel_item_create = ["a", "ctrl+n"]

        compress_file = ["C", "ctrl+a"]
        extract_file = ["X", "ctrl+e"]

        open_file_with_editor = ["e", ""]
        open_current_directory_with_editor = ["E", ""]

        toggle_dot_file = [".", "ctrl+h"]
        toggle_footer = ["F", ""]
        file_panel_select_mode_items_select_down = ["shift+down", "J"]
        file_panel_select_mode_items_select_up = ["shift+up", "K"]
        file_panel_select_all_items = ["A", ""]

        open_zoxide = ["z", ""]
        search_bar = ["/", ""]
        command_prompt = [":", ""]
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
            --set EDITOR "${self'.packages.helix}/bin/hx"
          [ -e $out/bin/spf ] || ln -sf $out/bin/superfile $out/bin/spf
        '';
      };
    in
    {
      packages.superfile = wrappedSuperfile;

      apps.superfile = {
        type = "app";
        program = "${wrappedSuperfile}/bin/superfile";
        meta.description = "Hermetically wrapped Superfile terminal file manager with Noctalia theme";
      };
    };
}