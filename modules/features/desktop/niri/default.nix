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
Mod + Return        Maximize column width
Mod + Shift + Ret   Fullscreen window
Mod + Space         Switch focus floating/tiling
Mod + Shift + Space Toggle focused window floating
Mod + A             Launcher: Noctalia App Runner
Mod + Shift + A     Overview: Niri Workspace View
Mod + Ctrl + A      Control Center: Noctalia Panel
Mod + S             Search: LibreWolf (Tiled)
Mod + Shift + S     Popup: Floating 16:9 LibreWolf
Mod + Ctrl + S      Private: LibreWolf Incognito
Mod + D             Dev: Ghostty Terminal (Tiled)
Mod + Shift + D     Popup: Floating 16:9 Scratchpad
Mod + Ctrl + D      Sessionizer: Fuzzy Project Tmux
Mod + F             Files: PCManFM File Manager (Tiled)
Mod + Shift + F     Popup: Floating 16:9 PCManFM
Mod + G             Notices: Noctalia Notification Center
Mod + Shift + G     Notices: Dismiss Active Notification
Mod + Ctrl + G      Bar: Toggle Noctalia Top Bar
Mod + Z             Notes: ZenNotes (Tiled)
Mod + Shift + Z     Popup: Floating 16:9 ZenNotes
Mod + X             Explore: nnn Helix Dashboard (Tiled)
Mod + Shift + X     Popup: Floating 16:9 nnn Dashboard
Mod + C             Universal Copy (Ctrl+Insert)
Mod + Shift + C     Universal Cut (Shift+Delete)
Mod + V             Universal Paste (Shift+Insert)
Mod + Shift + V     Clipboard History Panel
Mod + B             Bluetooth: Noctalia Panel
Mod + Shift + B     Bitwarden Desktop Client
Mod + Q             Close Focused Window
Mod + W             Wallpaper: Noctalia Panel
Mod + E             Audio: Pavucontrol Volume Mixer
Mod + Shift + E     Audio: EasyEffects DSP Effects
Mod + R             Snip: Area Screenshot to Clipboard
Mod + Shift + R     Snip: Fullscreen to Clipboard
Mod + T             Settings: Noctalia Settings GUI
Mod + P             Power: Noctalia Session Menu
Mod + Shift + P     Lock: Lock Screen
Mod + Ctrl + P      Monitors: Turn Off Displays
Mod + H / L         Navigate: Focus Column Left / Right
Mod + Shift + H / L Move: Move Column Left / Right
Mod + J / K         Workspace: Focus Workspace Down / Up
Mod + Shift + J / K Workspace: Move Column Down / Up
Mod + N / M         Stack: Focus Window Down / Up (Column)
Mod + Shift + N / M Stack: Move Window Down / Up (Column)
Mod + U / I         Stack: Consume / Expel Left / Right
Mod + Y / O         Width: Shrink / Expand Column Width
Mod + Shift + Y / O Height: Shrink / Expand Window Height
Mod + , / .         Monitor: Focus Monitor Left / Right
Mod + Shift + , / . Monitor: Move Column to Monitor L / R
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
        "@ghostty@"
        "@brave@"
        "@librewolf@"
        "@zennotes@"
        "@pcmanfm@"
        "@nnn@"
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
        "@wtype@"
      ]
      [
        outputConfig
        "${noctaliaPkg}/bin/noctalia"
        "${pkgs.systemd}/bin/systemctl"
        "${pkgs.ghostty}/bin/ghostty"
        "${lib.getExe pkgs.brave-origin}"
        "${pkgs.librewolf}/bin/librewolf"
        "${pkgs.zennotes-desktop}/bin/zennotes-desktop"
        "${pkgs.pcmanfm}/bin/pcmanfm"
        "${pkgs.nnn}/bin/nnn"
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
        "${pkgs.wtype}/bin/wtype"
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
          pkgs.nnn
        ];
      };
    };
}
