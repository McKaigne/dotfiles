{ inputs, ... }:
let
  makeNiriConfig =
    {
      pkgs,
      lib,
      noctaliaPkg,
      theme,
      palette,
      outputConfig ? "",
    }:
    let
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
        "@zellij@"
        "@easyeffects@"
        "@pavucontrol@"
        "@bitwarden@"
        "@screenshotArea@"
        "@screenshotFull@"
        "@brightnessUp@"
        "@brightnessDown@"
        "@cursorName@"
        "@cursorSize@"
        "@gaps@"
        "@borderWidth@"
        "@activeBorderColor@"
        "@inactiveBorderColor@"
        "@urgentBorderColor@"
        "@cornerRadius@"
        "@windowOpacity@"
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
        "${pkgs.zellij}/bin/zellij"
        "${pkgs.easyeffects}/bin/easyeffects"
        "${pkgs.pavucontrol}/bin/pavucontrol"
        "${pkgs.bitwarden-desktop}/bin/bitwarden"
        "${screenshotArea}/bin/screenshot-area"
        "${screenshotFull}/bin/screenshot-full"
        "${brightnessUp}/bin/brightness-up"
        "${brightnessDown}/bin/brightness-down"
        theme.cursor.name
        (toString theme.cursor.size)
        (toString theme.gap)
        (toString theme.borderWidth)
        palette.mauve
        palette.base
        palette.red
        (toString theme.radius)
        theme.opacity
      ]
      (builtins.readFile ./niri.kdl);
in
{
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
        inherit (config) theme;
        inherit (config) palette;
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
        programs.niri.useNautilus = false;

        services.greetd = {
          enable = true;
          settings = {
            default_session = {
              command = "${pkgs.niri}/bin/niri-session";
              inherit user;
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
