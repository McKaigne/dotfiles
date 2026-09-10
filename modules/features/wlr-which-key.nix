{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.wlr-which-key
    ];
  };
in
{
  flake.nixosModules.wlr-which-key = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      noctaliaBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell}/bin/noctalia-shell";
      ghosttyBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty}/bin/ghostty";
      niriBin = "${pkgs.niri}/bin/niri";

      whichKeyRuntimeDeps = with pkgs; [
        wlr-which-key
        gnugrep
        gnused
        coreutils
        ghostty
        tmux
        lazygit
        lazydocker
        self.packages.${pkgs.stdenv.hostPlatform.system}.btop
        localsend
        zenity
        wl-clipboard
        grim
        slurp
        tesseract
        hyprpicker
        libnotify
        wlsunset
        procps
        niri
        jq
      ];

      menuSnippetYaml = pkgs.writeText "menu-snippet.yaml" (lib.generators.toYAML {} {
        menu = [
          {
            key = [ "󱁐" "space" ];
            desc = "Launcher";
            cmd = "${noctaliaBin} ipc call launcher toggle || noctalia msg panel-toggle launcher";
          }
          {
            key = "t";
            desc = "Terminal";
            submenu = [
              {
                key = "a";
                desc = "Tmux Attach";
                cmd = "${ghosttyBin} -e ${pkgs.tmux}/bin/tmux attach";
              }
              {
                key = "g";
                desc = "Lazygit";
                cmd = "${ghosttyBin} -e ${pkgs.lazygit}/bin/lazygit";
              }
              {
                key = "d";
                desc = "Lazydocker";
                cmd = "${ghosttyBin} -e ${pkgs.lazydocker}/bin/lazydocker";
              }
              {
                key = "h";
                desc = "Herdr";
                cmd = "${ghosttyBin} -e sh -c 'command -v herdr >/dev/null 2>&1 && herdr || ${pkgs.tmux}/bin/tmux'";
              }
              {
                key = "b";
                desc = "Btop";
                cmd = "${ghosttyBin} -e ${self.packages.${pkgs.stdenv.hostPlatform.system}.btop}/bin/btop";
              }
            ];
          }
          {
            key = "l";
            desc = "LocalSend";
            submenu = [
              {
                key = "c";
                desc = "Send Clipboard";
                cmd = "sh -c 'f=/tmp/localsend_clip.txt; ${pkgs.wl-clipboard}/bin/wl-paste > \"$f\" && ${pkgs.localsend}/bin/localsend \"$f\"'";
              }
              {
                key = "f";
                desc = "Send File";
                cmd = "sh -c 'f=$(${pkgs.zenity}/bin/zenity --file-selection --title=\"Select File to Send\") && [ -n \"$f\" ] && ${pkgs.localsend}/bin/localsend \"$f\"'";
              }
              {
                key = "d";
                desc = "Send Folder";
                cmd = "sh -c 'd=$(${pkgs.zenity}/bin/zenity --file-selection --directory --title=\"Select Folder to Send\") && [ -n \"$d\" ] && ${pkgs.localsend}/bin/localsend \"$d\"'";
              }
              {
                key = "r";
                desc = "Receive";
                cmd = "${pkgs.localsend}/bin/localsend";
              }
            ];
          }
          {
            key = "n";
            desc = "Noctalia";
            submenu = [
              {
                key = "l";
                desc = "Night Light Toggle";
                cmd = "sh -c '${noctaliaBin} ipc call nightLight toggle || ${pkgs.procps}/bin/pkill wlsunset || ${pkgs.wlsunset}/bin/wlsunset -T 4000 &'";
              }
              {
                key = "a";
                desc = "Night Light Auto";
                cmd = "sh -c '${noctaliaBin} ipc call nightLight auto || ${pkgs.wlsunset}/bin/wlsunset -l 14.6 -L 121.0 &'";
              }
              {
                key = "s";
                desc = "Silence Notifications";
                cmd = "${noctaliaBin} ipc call notifications toggleSilence || noctalia msg dnd-toggle";
              }
              {
                key = "c";
                desc = "Clipboard History";
                cmd = "${noctaliaBin} ipc call launcher clipboard || noctalia msg panel-toggle clipboard";
              }
              {
                key = "p";
                desc = "Color Picker";
                cmd = "sh -c 'color=$(${pkgs.hyprpicker}/bin/hyprpicker -a) && [ -n \"$color\" ] && ${pkgs.libnotify}/bin/notify-send \"Color Picked\" \"$color\" -i color-select'";
              }
              {
                key = "o";
                desc = "OCR Extraction";
                cmd = "sh -c '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.tesseract}/bin/tesseract stdin stdout -l eng 2>/dev/null | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send \"OCR Extracted\" \"Copied text to clipboard\"'";
              }
              {
                key = "b";
                desc = "Toggle Bar";
                cmd = "${noctaliaBin} ipc call bar toggle || noctalia msg bar-toggle";
              }
            ];
          }
          {
            key = "w";
            desc = "Window";
            submenu = [
              {
                key = "o";
                desc = "Only Current Window";
                cmd = "sh -c 'cur=$(${niriBin} msg -j focused-window | ${pkgs.jq}/bin/jq -r .id); for id in $(${niriBin} msg -j windows | ${pkgs.jq}/bin/jq -r \".[] | select(.id != $cur) | .id\"); do ${niriBin} msg action close-window --id \"$id\"; done'";
              }
              {
                key = "c";
                desc = "Close All Windows";
                cmd = "sh -c 'for id in $(${niriBin} msg -j windows | ${pkgs.jq}/bin/jq -r \".[] | .id\"); do ${niriBin} msg action close-window --id \"$id\"; done'";
              }
              {
                key = "t";
                desc = "Toggle Float / Tile";
                cmd = "${niriBin} msg action toggle-window-floating";
              }
              {
                key = "f";
                desc = "Fullscreen";
                cmd = "${niriBin} msg action fullscreen-window";
              }
              {
                key = "w";
                desc = "Maximize Width";
                cmd = "${niriBin} msg action maximize-column";
              }
              {
                key = "e";
                desc = "Reset Height";
                cmd = "${niriBin} msg action reset-window-height";
              }
              {
                key = ",";
                desc = "Consume into Column";
                cmd = "${niriBin} msg action consume-window-into-column";
              }
              {
                key = ".";
                desc = "Expel from Column";
                cmd = "${niriBin} msg action expel-window-from-column";
              }
            ];
          }
          {
            key = "s";
            desc = "System";
            submenu = [
              {
                key = "s";
                desc = "Power Menu";
                cmd = "${noctaliaBin} ipc call sessionMenu toggle || noctalia msg panel-toggle session-menu";
              }
              {
                key = "l";
                desc = "Lock Screen";
                cmd = "sh -c 'loginctl lock-session || ${noctaliaBin} ipc call lockScreen lock'";
              }
              {
                key = "z";
                desc = "Suspend";
                cmd = "systemctl suspend";
              }
              {
                key = "r";
                desc = "Reboot";
                cmd = "systemctl reboot";
              }
            ];
          }
        ];
      });

      menuScript = pkgs.writeShellScriptBin "wlr-which-key-menu" ''
        set -euo pipefail

        BG="#1e2326f0"
        FG="#d3c6aa"
        BORDER="#a7c080"

        # Dynamically auto-theme from live Noctalia wallpaper palette
        FUZZEL_THEME="$HOME/.config/fuzzel/themes/noctalia"
        if [ -f "$FUZZEL_THEME" ]; then
            raw_bg=$(${pkgs.gnugrep}/bin/grep -E '^background=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | cut -c1-6 || true)
            raw_fg=$(${pkgs.gnugrep}/bin/grep -E '^text=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | cut -c1-6 || true)
            raw_border=$(${pkgs.gnugrep}/bin/grep -E '^(match|border)=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | cut -c1-6 || true)

            [ -n "$raw_bg" ] && [ "''${#raw_bg}" -eq 6 ] && BG="#''${raw_bg}f0"
            [ -n "$raw_fg" ] && [ "''${#raw_fg}" -eq 6 ] && FG="#''${raw_fg}"
            [ -n "$raw_border" ] && [ "''${#raw_border}" -eq 6 ] && BORDER="#''${raw_border}"
        fi

        LIVE_CONFIG="''${XDG_RUNTIME_DIR:-/tmp}/wlr-which-key-live.yaml"

        ${pkgs.coreutils}/bin/cat << EOF > "$LIVE_CONFIG"
        font: Maple Mono NF 12
        background: "$BG"
        color: "$FG"
        border: "$BORDER"
        border_width: 1
        corner_r: 1.5
        padding: 15
        rows_per_column: 6
        column_padding: 30
        anchor: center
        separator: " ➜ "
        inhibit_compositor_keyboard_shortcuts: true
        EOF

        ${pkgs.coreutils}/bin/cat "${menuSnippetYaml}" >> "$LIVE_CONFIG"

        exec ${pkgs.lib.getExe pkgs.wlr-which-key} "$LIVE_CONFIG"
      '';

      wrappedWhichKey = pkgs.symlinkJoin {
        name = "wlr-which-key";
        paths = [ menuScript ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/wlr-which-key-menu \
            --prefix PATH : ${lib.makeBinPath whichKeyRuntimeDeps}
          ln -sf $out/bin/wlr-which-key-menu $out/bin/wlr-which-key
        '';
      };
    in
    {
      packages.wlr-which-key = wrappedWhichKey;

      apps.wlr-which-key = {
        type = "app";
        program = "${wrappedWhichKey}/bin/wlr-which-key-menu";
        meta.description = "Auto-themed wlr-which-key modal menu matching Noctalia palette";
      };
    };
}