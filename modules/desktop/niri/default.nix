{ config, pkgs, inputs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  user = config.mainUser;
  userHome = config.users.users.${user}.home;

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
    ${pkgs.brightnessctl}/bin/brightnessctl set +5%
  '';

  brightnessDown = pkgs.writeShellScriptBin "brightness-down" ''
    set -euo pipefail
    curr=$(${pkgs.brightnessctl}/bin/brightnessctl get)
    max=$(${pkgs.brightnessctl}/bin/brightnessctl max)
    new=$((curr - max * 5 / 100))
    if [ "$new" -lt "$((max * 5 / 100))" ]; then
      ${pkgs.brightnessctl}/bin/brightnessctl set 5%
    else
      ${pkgs.brightnessctl}/bin/brightnessctl set 5%-
    fi
  '';

  zellijFocus = pkgs.writeShellScriptBin "zellij-focus" ''
    set -euo pipefail
    WINDOW_ID=$(${pkgs.niri}/bin/niri msg -j windows 2>/dev/null | \
      ${pkgs.jq}/bin/jq -r '.[] | select((.app_id == "ghostty.zellij") or (.title | test("zellij-terminal"; "i"))) | .id' | head -n1 || true)
    if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
      ${pkgs.niri}/bin/niri msg action focus-window --id "$WINDOW_ID"
    else
      exec ${pkgs.ghostty}/bin/ghostty \
        --class="ghostty.zellij" --title="zellij-terminal" \
        -e ${pkgs.zellij}/bin/zellij attach --create
    fi
  '';

  zellijAttach = pkgs.writeShellScriptBin "zellij-attach" ''
    set -euo pipefail
    exec ${pkgs.ghostty}/bin/ghostty \
      --class="ghostty.zellij-picker" --title="zellij-session-picker" \
      -e ${pkgs.zellij}/bin/zellij attach --create
  '';

  helixFocus = pkgs.writeShellScriptBin "helix-focus" ''
    set -euo pipefail
    WINDOW_ID=$(${pkgs.niri}/bin/niri msg -j windows 2>/dev/null | \
      ${pkgs.jq}/bin/jq -r '.[] | select((.app_id == "ghostty.helix") or (.title | test("helix-editor"; "i"))) | .id' | head -n1 || true)
    if [ -n "$WINDOW_ID" ] && [ "$WINDOW_ID" != "null" ]; then
      ${pkgs.niri}/bin/niri msg action focus-window --id "$WINDOW_ID"
    else
      exec ${pkgs.ghostty}/bin/ghostty \
        --class="ghostty.helix" --title="helix-editor" \
        -e ${pkgs.helix}/bin/hx
    fi
  '';

  noctaliaPkg = inputs.noctalia.packages.${system}.default;
  heliumPkg = inputs.helium.packages.${system}.default;

  niriConfigRaw = builtins.replaceStrings
    [
      "@userHome@"
      "@noctalia@"
      "@xwaylandSatellite@"
      "@systemctl@"
      "@ghostty@"
      "@qutebrowser@"
      "@helium@"
      "@nautilus@"
      "@pearDesktop@"
      "@fuzzel@"
      "@wpctl@"
      "@playerctl@"
      "@zellijFocus@"
      "@zellijAttach@"
      "@helixFocus@"
      "@lazygit@"
      "@easyeffects@"
      "@pavucontrol@"
      "@screenshotArea@"
      "@screenshotFull@"
      "@brightnessUp@"
      "@brightnessDown@"
    ]
    [
      userHome
      "${noctaliaPkg}/bin/noctalia"
      "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
      "${pkgs.systemd}/bin/systemctl"
      "${pkgs.ghostty}/bin/ghostty"
      "${pkgs.qutebrowser}/bin/qutebrowser"
      "${heliumPkg}/bin/helium"
      "${pkgs.nautilus}/bin/nautilus"
      "${pkgs.pear-desktop}/bin/pear-desktop"
      "${pkgs.fuzzel}/bin/fuzzel"
      "${pkgs.wireplumber}/bin/wpctl"
      "${pkgs.playerctl}/bin/playerctl"
      "${zellijFocus}/bin/zellij-focus"
      "${zellijAttach}/bin/zellij-attach"
      "${helixFocus}/bin/helix-focus"
      "${pkgs.lazygit}/bin/lazygit"
      "${pkgs.easyeffects}/bin/easyeffects"
      "${pkgs.pavucontrol}/bin/pavucontrol"
      "${screenshotArea}/bin/screenshot-area"
      "${screenshotFull}/bin/screenshot-full"
      "${brightnessUp}/bin/brightness-up"
      "${brightnessDown}/bin/brightness-down"
    ]
    (builtins.readFile ./config.kdl);
in
{
  programs.niri.enable = true;

  home-manager.users.${user} = {
    xdg.configFile."niri/config.kdl".text = niriConfigRaw;
  };

  environment.systemPackages = [
    pkgs.xwayland-satellite
  ];

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = [ "gnome" "gtk" ];
    };
  };
}
