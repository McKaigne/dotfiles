
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
        full_screen_fg = "#cdd6f4"
        full_screen_bg = "#1e1e2e"
        file_panel_fg = "#cdd6f4"
        file_panel_bg = "#1e1e2e"
        file_panel_border = "#313244"
        file_panel_border_active = "#cba6f7"
        sidebar_fg = "#cdd6f4"
        sidebar_bg = "#1e1e2e"
        sidebar_title = "#cba6f7"
        sidebar_border = "#313244"
        sidebar_border_active = "#cba6f7"
        cursor = "#cba6f7"
        correct = "#a6e3a1"
        error = "#f38ba8"
        hint = "#f9e2af"
      '';

      spfConfig = pkgs.writeText "config.toml" ''
        theme = "noctalia"
        editor = "hx"
        dir_editor = "hx"
        auto_check_update = false
        cd_on_quit = true
        default_open_file_preview = true
        default_directory = "."
        nerdfont = true
        transparent_background = false
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
        meta.description = "Hermetically wrapped Superfile terminal file manager";
      };
    };
}
