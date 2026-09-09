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
      whichKeyRuntimeDeps = with pkgs; [
        wlr-which-key
        gnugrep
        gnused
        coreutils
        ghostty
        tmux
        lazygit
        lazydocker
        btop
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

      noctaliaBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell}/bin/noctalia-shell";
      ghosttyBin = "${self.packages.${pkgs.stdenv.hostPlatform.system}.ghostty}/bin/ghostty";
      niriBin = "${pkgs.niri}/bin/niri";

      menuData = {
        font = "Maple Mono NF 13";
        background = "@BG@";
        color = "@FG@";
        border = "@BORDER@";
        separator = "  ";
        border_width = 2;
        corner_r = 1234567;
        padding = 22;
        rows_per_column = 6;
        column_padding = 32;
        anchor = "center";
        inhibit_compositor_keyboard_shortcuts = true;
        menu = [
          {
            key = [ "space" " " ];
            desc = "󱓞  Noctalia Launcher";
            cmd = "${noctaliaBin} ipc call launcher toggle || noctalia msg panel-toggle launcher";
          }
          {
            key = "t";
            desc = "  Terminal & Tools";
            submenu = [
              {
                key = "a";
                desc = "󰒍  Tmux Attach";
                cmd = "${ghosttyBin} -e ${pkgs.tmux}/bin/tmux attach";
              }
              {
                key = "g";
                desc = "  Lazygit";
                cmd = "${ghosttyBin} -e ${pkgs.lazygit}/bin/lazygit";
              }
              {
                key = "d";
                desc = "󰡨  Lazydocker";
                cmd = "${ghosttyBin} -e ${pkgs.lazydocker}/bin/lazydocker";
              }
              {
                key = "h";
                desc = "󰹑  Herdr Multiplexer";
                cmd = "${ghosttyBin} -e sh -c 'command -v herdr >/dev/null 2>&1 && herdr || ${pkgs.tmux}/bin/tmux'";
              }
              {
                key = "b";
                desc = "󰄧  Btop Monitor";
                cmd = "${ghosttyBin} -e ${pkgs.btop}/bin/btop";
              }
            ];
          }
          {
            key = "l";
            desc = "󱅻  LocalSend Transfer";
            submenu = [
              {
                key = "c";
                desc = "󰅍  Send Clipboard";
                cmd = "sh -c 'f=/tmp/localsend_clip.txt; ${pkgs.wl-clipboard}/bin/wl-paste > \"$f\" && ${pkgs.localsend}/bin/localsend \"$f\"'";
              }
              {
                key = "f";
                desc = "󰈔  Send File";
                cmd = "sh -c 'f=$(${pkgs.zenity}/bin/zenity --file-selection --title=\"Select File to Send\") && [ -n \"$f\" ] && ${pkgs.localsend}/bin/localsend \"$f\"'";
              }
              {
                key = "d";
                desc = "󰉋  Send Folder";
                cmd = "sh -c 'd=$(${pkgs.zenity}/bin/zenity --file-selection --directory --title=\"Select Folder to Send\") && [ -n \"$d\" ] && ${pkgs.localsend}/bin/localsend \"$d\"'";
              }
              {
                key = "r";
                desc = "󰇚  Receive (Open App)";
                cmd = "${pkgs.localsend}/bin/localsend";
              }
            ];
          }
          {
            key = "n";
            desc = "󱨦  Noctalia & Controls";
            submenu = [
              {
                key = "l";
                desc = "󰖔  Toggle Night Light";
                cmd = "sh -c '${noctaliaBin} ipc call nightLight toggle || ${pkgs.procps}/bin/pkill wlsunset || ${pkgs.wlsunset}/bin/wlsunset -T 4000 &'";
              }
              {
                key = "a";
                desc = "󰖕  Night Light Auto";
                cmd = "sh -c '${noctaliaBin} ipc call nightLight auto || ${pkgs.wlsunset}/bin/wlsunset -l 14.6 -L 121.0 &'";
              }
              {
                key = "s";
                desc = "󰂛  Silence Notifications";
                cmd = "${noctaliaBin} ipc call notifications toggleSilence || noctalia msg dnd-toggle";
              }
              {
                key = "c";
                desc = "󱉥  Clipboard History";
                cmd = "${noctaliaBin} ipc call launcher clipboard || noctalia msg panel-toggle clipboard";
              }
              {
                key = "p";
                desc = "󰈋  Color Picker";
                cmd = "sh -c 'color=$(${pkgs.hyprpicker}/bin/hyprpicker -a) && [ -n \"$color\" ] && ${pkgs.libnotify}/bin/notify-send \"Color Picked\" \"$color\" -i color-select'";
              }
              {
                key = "o";
                desc = "󰚢  OCR Text Extraction";
                cmd = "sh -c '${pkgs.grim}/bin/grim -g \"$(${pkgs.slurp}/bin/slurp)\" - | ${pkgs.tesseract}/bin/tesseract stdin stdout -l eng 2>/dev/null | ${pkgs.wl-clipboard}/bin/wl-copy && ${pkgs.libnotify}/bin/notify-send \"OCR Extracted\" \"Copied text to clipboard\"'";
              }
              {
                key = "b";
                desc = "󱂬  Toggle Top Bar";
                cmd = "${noctaliaBin} ipc call bar toggle || noctalia msg bar-toggle";
              }
            ];
          }
          {
            key = "w";
            desc = "󰖲  Window & Layout";
            submenu = [
              {
                key = "o";
                desc = "󰖯  Only Current Window";
                cmd = "sh -c 'cur=$(${niriBin} msg -j focused-window | ${pkgs.jq}/bin/jq -r .id); for id in $(${niriBin} msg -j windows | ${pkgs.jq}/bin/jq -r \".[] | select(.id != $cur) | .id\"); do ${niriBin} msg action close-window --id \"$id\"; done'";
              }
              {
                key = "c";
                desc = "󰅖  Close All Windows";
                cmd = "sh -c 'for id in $(${niriBin} msg -j windows | ${pkgs.jq}/bin/jq -r \".[] | .id\"); do ${niriBin} msg action close-window --id \"$id\"; done'";
              }
              {
                key = "t";
                desc = "󰉈  Toggle Float / Tile";
                cmd = "${niriBin} msg action toggle-window-floating";
              }
              {
                key = "f";
                desc = "󰊓  Fullscreen Window";
                cmd = "${niriBin} msg action fullscreen-window";
              }
              {
                key = "w";
                desc = "󰹚  Maximize Column";
                cmd = "${niriBin} msg action maximize-column";
              }
              {
                key = "e";
                desc = "󰁌  Reset Window Height";
                cmd = "${niriBin} msg action reset-window-height";
              }
              {
                key = ",";
                desc = "󰍡  Consume into Column";
                cmd = "${niriBin} msg action consume-window-into-column";
              }
              {
                key = ".";
                desc = "󰍢  Expel from Column";
                cmd = "${niriBin} msg action expel-window-from-column";
              }
            ];
          }
          {
            key = "s";
            desc = "󰐥  System & Power";
            submenu = [
              {
                key = "s";
                desc = "󰐥  Noctalia Power Menu";
                cmd = "${noctaliaBin} ipc call sessionMenu toggle || noctalia msg panel-toggle session-menu";
              }
              {
                key = "l";
                desc = "󰌾  Lock Screen";
                cmd = "sh -c 'loginctl lock-session || ${noctaliaBin} ipc call lockScreen lock'";
              }
              {
                key = "z";
                desc = "󰒲  Suspend System";
                cmd = "systemctl suspend";
              }
              {
                key = "r";
                desc = "󰜉  Reboot System";
                cmd = "systemctl reboot";
              }
            ];
          }
        ];
      };

      baseConfigYaml = pkgs.writeText "wlr-which-key-template.yaml" (lib.generators.toYAML {} menuData);

      wrapperScript = pkgs.writeShellScriptBin "wlr-which-key-menu" ''
        set -euo pipefail

        BG="#1e2326f2"
        FG="#d3c6aa"
        BORDER="#a7c080"
        RADIUS=12

        # 1. Extract dynamic palette from live Noctalia theme
        FUZZEL_THEME="$HOME/.config/fuzzel/themes/noctalia"
        if [ -f "$FUZZEL_THEME" ]; then
            raw_bg=$(${pkgs.gnugrep}/bin/grep -E '^background=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | ${pkgs.coreutils}/bin/cut -c1-6 || true)
            raw_fg=$(${pkgs.gnugrep}/bin/grep -E '^text=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | ${pkgs.coreutils}/bin/cut -c1-6 || true)
            raw_border=$(${pkgs.gnugrep}/bin/grep -E '^(match|border)=' "$FUZZEL_THEME" 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.coreutils}/bin/cut -d= -f2 | ${pkgs.coreutils}/bin/tr -d ' #' | ${pkgs.coreutils}/bin/cut -c1-6 || true)

            [ -n "$raw_bg" ] && [ "''${#raw_bg}" -eq 6 ] && BG="#''${raw_bg}f2"
            [ -n "$raw_fg" ] && [ "''${#raw_fg}" -eq 6 ] && FG="#''${raw_fg}"
            [ -n "$raw_border" ] && [ "''${#raw_border}" -eq 6 ] && BORDER="#''${raw_border}"
        fi

        # 2. Extract container corner radius dynamically from Noctalia
        if [ -f "$HOME/.config/noctalia/settings.json" ]; then
            r=$(${pkgs.jq}/bin/jq -r '.radius // .["bar.default"].radius // .bar.default.radius // empty' "$HOME/.config/noctalia/settings.json" 2>/dev/null || true)
            [ -n "$r" ] && [ "$r" != "null" ] && RADIUS="$r"
        elif [ -f "$HOME/.config/niri/noctalia.kdl" ]; then
            r=$(${pkgs.gnugrep}/bin/grep -m1 -oE 'geometry-corner-radius[ ]+[0-9]+' "$HOME/.config/niri/noctalia.kdl" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+' || true)
            [ -n "$r" ] && RADIUS="$r"
        elif [ -f "$HOME/.config/gtk-3.0/noctalia.css" ]; then
            r=$(${pkgs.gnugrep}/bin/grep -m1 -oE 'border-radius:[ ]*[0-9]+' "$HOME/.config/gtk-3.0/noctalia.css" 2>/dev/null | ${pkgs.gnugrep}/bin/grep -oE '[0-9]+' || true)
            [ -n "$r" ] && RADIUS="$r"
        fi

        RUN_DIR="''${XDG_RUNTIME_DIR:-/tmp}/wlr-which-key"
        ${pkgs.coreutils}/bin/mkdir -p "$RUN_DIR"
        LIVE_CONFIG="$RUN_DIR/config.yaml"

        ${pkgs.gnused}/bin/sed -e "s|@BG@|$BG|g" \
            -e "s|@FG@|$FG|g" \
            -e "s|@BORDER@|$BORDER|g" \
            -e "s/1234567/$RADIUS/g" \
            "${baseConfigYaml}" > "$LIVE_CONFIG"

        exec "${pkgs.wlr-which-key}/bin/wlr-which-key" "$LIVE_CONFIG" "$@"
      '';

      wrappedWhichKey = pkgs.symlinkJoin {
        name = "wlr-which-key";
        paths = [ wrapperScript ];
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
        meta.description = "Hermetically wrapped wlr-which-key menu with Noctalia theme bridge";
      };
    };
}