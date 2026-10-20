{ self, inputs, ... }:
let
  makeNiriWrapper =
    { pkgs, lib }:
    pkgs.symlinkJoin {
      name = "niri-wrapped";
      paths = [ pkgs.niri ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/niri \
          --prefix PATH : "${
            lib.makeBinPath [
              pkgs.xwayland-satellite
              pkgs.grim
              pkgs.slurp
              pkgs.wl-clipboard
              pkgs.wtype
              pkgs.brightnessctl
              pkgs.ddcutil
              pkgs.playerctl
              pkgs.wireplumber
              pkgs.fuzzel
              pkgs.jq
            ]
          }"
      '';
      passthru = (pkgs.niri.passthru or { }) // {
        providedSessions = [ "niri" ];
      };
    };

  makeNiriConfig =
    {
      pkgs,
      lib,
      noctaliaPkg,
      outputConfig ? "",
    }:
    let
      tmuxSessionizer = pkgs.writeShellScriptBin "tmux-sessionizer" ''
        set -euo pipefail
        target=$( (
          echo "$HOME/.config"
          echo "/etc/nixos"
          [ -d "$HOME/projects" ] && find "$HOME/projects" -mindepth 1 -maxdepth 2 -type d 2>/dev/null
          [ -d "$HOME/dev" ] && find "$HOME/dev" -mindepth 1 -maxdepth 2 -type d 2>/dev/null
          ${pkgs.zoxide}/bin/zoxide query -l 2>/dev/null
        ) | grep -v -E '/\.git(/|$)' | awk '!seen[$0]++' | ${pkgs.fzf}/bin/fzf --reverse --header="Select project session:" )

        if [ -z "$target" ]; then
          exit 0
        fi

        session_name=$(basename "$target" | tr '.' '_')

        if ! ${pkgs.tmux}/bin/tmux has-session -t "$session_name" 2>/dev/null; then
          ${pkgs.tmux}/bin/tmux new-session -d -s "$session_name" -c "$target"
        fi

        if [ -n "''${TMUX:-}" ]; then
          ${pkgs.tmux}/bin/tmux switch-client -t "$session_name"
        else
          exec ${pkgs.tmux}/bin/tmux attach-session -t "$session_name"
        fi
      '';

      fuzzelCheatsheet = pkgs.writeShellScriptBin "fuzzel-cheatsheet" ''
        set -euo pipefail
        cat << 'SHEET_EOF' | ${pkgs.fuzzel}/bin/fuzzel --dmenu --prompt "⌨ Keybinds ➜ " --lines 18 --width 54
Mod + Space         Fill Screen (Maximize Column Width)
Mod + Shift + Space Fullscreen Window
Mod + Ctrl + Space  Toggle Window Floating
Mod + Alt + Space   Switch Focus Floating/Tiling
Mod + F             Terminal: Foot Client (Fast Daemon)
Mod + Shift + F     Terminal: Ghostty Standalone
Mod + Ctrl + F      Terminal: Tmux Project Sessionizer
Mod + D             Browser: LibreWolf
Mod + Shift + D     Browser: Brave Origin
Mod + Ctrl + D      Browser: LibreWolf Private
Mod + S             Files: PCManFM File Manager
Mod + Shift + S     Files: Floating PCManFM Dialog
Mod + Ctrl + S      Terminal in Current Directory
Mod + A             Chat: Ferdium Messaging Client
Mod + Shift + A     Overview: Niri Workspace View
Mod + Ctrl + A      Chat: Floating Ferdium
Mod + G             Notes: Obsidian Knowledge Vault
Mod + Shift + G     Notes: Floating Obsidian Quick Note
Mod + Ctrl + G      Notes: Obsidian Daily Note
Mod + T             Snip: Area Screenshot to Clipboard
Mod + Shift + T     Snip: Fullscreen to Clipboard
Mod + Ctrl + T      Screen Recording / OCR
Mod + E             Notices: Notification Center Panel
Mod + Shift + E     Notices: Clear All Notice History
Mod + X             Notices: Dismiss Active Notification
Mod + Shift + X     Notices: Dismiss All Popups
Mod + V             Settings: Noctalia Settings GUI
Mod + Shift + V     Clipboard: Noctalia History Panel
Mod + C             Control: Noctalia Control Center Panel
Mod + Shift + C     Audio: Pavucontrol Volume Mixer
Mod + B             Bluetooth: Noctalia Bluetooth Panel
Mod + Shift + B     Security: Bitwarden Desktop Client
Mod + W             Network: Wi-Fi / Network Panel
Mod + Shift + W     Wallpaper: Noctalia Wallpaper Selector
Mod + Ctrl + W      Bar: Toggle Noctalia Top Bar
Mod + R             Launcher: Noctalia App Runner
Mod + Shift + R     Interactive Fuzzel Hotkey Search
Mod + Esc           Session: Noctalia Power Menu
Mod + Shift + Esc   Session: Lock Screen
Mod + Ctrl + Esc    Monitors: Turn Off Displays
Mod + Q             Close Focused Window
Mod + Shift + Q     Kill / Force Close Window
Mod + H / L         Navigate: Focus Column Left / Right
Mod + J / K         Stack: Focus Window Down / Up (Column)
Mod + Shift + H / L Move: Move Column Left / Right
Mod + Shift + J / K Move: Move Window Down / Up (Column)
Mod + Ctrl + H / L  Resize: Shrink / Expand Column Width
Mod + Ctrl + J / K  Resize: Shrink / Expand Window Height
Mod + U / I         Workspace: Focus Workspace Down / Up
Mod + Shift + U / I Workspace: Move Column Down / Up
Mod + M             Stack: Consume Window Left
Mod + , (Comma)     Stack: Consume Window Right
Mod + . (Period)    Stack: Expel Window from Column
Mod + 1..9          Workspace: Focus Named "one".."nine"
Mod + 0             Workspace: Focus Dynamic 10th
SHEET_EOF
      '';

      screenshotArea = pkgs.writeShellScriptBin "screenshot-area" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      screenshotFull = pkgs.writeShellScriptBin "screenshot-full" ''
        set -euo pipefail
        ${pkgs.grim}/bin/grim - | ${pkgs.wl-clipboard}/bin/wl-copy
      '';

      brightnessUp = pkgs.writeShellScriptBin "brightness-up" ''
        set -euo pipefail
        if command -v noctalia >/dev/null 2>&1 && noctalia msg ping >/dev/null 2>&1; then
          noctalia msg brightness-up 5
        elif [ -d /sys/class/backlight ] && [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
          ${pkgs.brightnessctl}/bin/brightnessctl set +5%
        else
          ${pkgs.ddcutil}/bin/ddcutil setvcp 10 + 5 2>/dev/null || true
        fi
      '';

      brightnessDown = pkgs.writeShellScriptBin "brightness-down" ''
        set -euo pipefail
        if command -v noctalia >/dev/null 2>&1 && noctalia msg ping >/dev/null 2>&1; then
          noctalia msg brightness-down 5
        elif [ -d /sys/class/backlight ] && [ -n "$(ls -A /sys/class/backlight 2>/dev/null)" ]; then
          curr=$(${pkgs.brightnessctl}/bin/brightnessctl get)
          max=$(${pkgs.brightnessctl}/bin/brightnessctl max)
          new=$((curr - max * 5 / 100))
          if [ "$new" -lt "$((max * 5 / 100))" ]; then
            ${pkgs.brightnessctl}/bin/brightnessctl set 5%
          else
            ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
          fi
        else
          ${pkgs.ddcutil}/bin/ddcutil setvcp 10 - 5 2>/dev/null || true
        fi
      '';
    in
    builtins.replaceStrings
      [
        "@outputConfig@"
        "@noctalia@"
        "@systemctl@"
        "@footclient@"
        "@ghostty@"
        "@brave@"
        "@librewolf@"
        "@obsidian@"
        "@pcmanfm@"
        "@ferdium@"
        "@wpctl@"
        "@playerctl@"
        "@tmuxSessionizer@"
        "@fuzzelCheatsheet@"
        "@easyeffects@"
        "@pavucontrol@"
        "@screenshotArea@"
        "@screenshotFull@"
        "@brightnessUp@"
        "@brightnessDown@"
      ]
      [
        outputConfig
        "${noctaliaPkg}/bin/noctalia"
        "${pkgs.systemd}/bin/systemctl"
        "${pkgs.foot}/bin/footclient"
        "${pkgs.ghostty}/bin/ghostty"
        "${lib.getExe pkgs.brave-origin}"
        "${pkgs.librewolf}/bin/librewolf"
        "${pkgs.obsidian}/bin/obsidian"
        "${pkgs.pcmanfm}/bin/pcmanfm"
        "${pkgs.ferdium}/bin/ferdium"
        "${pkgs.wireplumber}/bin/wpctl"
        "${pkgs.playerctl}/bin/playerctl"
        "${tmuxSessionizer}/bin/tmux-sessionizer"
        "${fuzzelCheatsheet}/bin/fuzzel-cheatsheet"
        "${pkgs.easyeffects}/bin/easyeffects"
        "${pkgs.pavucontrol}/bin/pavucontrol"
        "${screenshotArea}/bin/screenshot-area"
        "${screenshotFull}/bin/screenshot-full"
        "${brightnessUp}/bin/brightness-up"
        "${brightnessDown}/bin/brightness-down"
      ]
      (builtins.readFile ./niri.kdl);
in
{
  perSystem =
    {
      pkgs,
      lib,
      ...
    }:
    {
      packages.myNiri = makeNiriWrapper { inherit pkgs lib; };
    };

  flake.nixosModules.niri =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      user = config.mainUser;
      system = pkgs.stdenv.hostPlatform.system;
      myNiri = makeNiriWrapper { inherit pkgs lib; };
      noctaliaPkg = inputs.noctalia.packages.${system}.default;
      displayCfg = config.workstation.display;
      modeLine = lib.optionalString (displayCfg.mode != null) "  mode \"${displayCfg.mode}\"\n";
      renderedOutputConfig = ''
        output "${displayCfg.output}" {
        ${modeLine}  scale ${displayCfg.scale}
        }
      '';
      niriConfigText = makeNiriConfig {
        inherit
          pkgs
          lib
          noctaliaPkg
          ;
        outputConfig = renderedOutputConfig;
      };
    in
    {
      options.workstation.display = {
        output = lib.mkOption {
          type = lib.types.str;
          default = "DP-1";
          description = "Primary display connector identifier.";
        };
        mode = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "Display resolution and refresh rate string. If null, display default is used.";
        };
        scale = lib.mkOption {
          type = lib.types.str;
          default = "1.0";
          description = "Display output scaling factor.";
        };
      };

      config = {
        programs.niri.enable = true;
        programs.niri.package = myNiri;
        programs.niri.useNautilus = false;

        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${myNiri}/bin/niri-session";
              user = user;
            };
          };
        };

        home-manager.users.${user} = {
          xdg.configFile."niri/config.kdl" = {
            text = niriConfigText;
            force = true;
          };
        };

        environment.systemPackages = [
          pkgs.xwayland-satellite
          pkgs.ddcutil
          pkgs.wtype
        ];
      };
    };
}
