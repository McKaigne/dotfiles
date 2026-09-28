{ self, ... }:
let
  nixosModule = { config, pkgs, ... }:
    let
      system = pkgs.stdenv.hostPlatform.system;
      userHome = config.users.users.${config.mainUser}.home;

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

      niriConfig = pkgs.writeText "niri-config.kdl" (builtins.replaceStrings
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
          "@tmuxSessionizer@"
          "@helixTmuxFocus@"
          "@tmuxTermFocus@"
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
          "${self.packages.${system}.noctalia}/bin/noctalia"
          "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
          "${pkgs.systemd}/bin/systemctl"
          "${self.packages.${system}.ghostty}/bin/ghostty"
          "${self.packages.${system}.qutebrowser}/bin/qutebrowser"
          "${self.packages.${system}.helium}/bin/helium"
          "${pkgs.nautilus}/bin/nautilus"
          "${pkgs.pear-desktop}/bin/pear-desktop"
          "${self.packages.${system}.fuzzel}/bin/fuzzel"
          "${pkgs.wireplumber}/bin/wpctl"
          "${pkgs.playerctl}/bin/playerctl"
          "${self.packages.${system}.tmux-sessionizer}/bin/tmux-sessionizer"
          "${self.packages.${system}.helix-tmux-focus}/bin/helix-tmux-focus"
          "${self.packages.${system}.tmux-term-focus}/bin/tmux-term-focus"
          "${pkgs.lazygit}/bin/lazygit"
          "${self.packages.${system}.easyeffects}/bin/easyeffects"
          "${pkgs.pavucontrol}/bin/pavucontrol"
          "${screenshotArea}/bin/screenshot-area"
          "${screenshotFull}/bin/screenshot-full"
          "${brightnessUp}/bin/brightness-up"
          "${brightnessDown}/bin/brightness-down"
        ]
        (builtins.readFile ./config.kdl)
      );

      wrappedNiri = pkgs.symlinkJoin {
        name = "niri-wrapped";
        paths = [ pkgs.niri ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        passthru = (pkgs.niri.passthru or { }) // {
          providedSessions = [ "niri" ];
        };
        postBuild = ''
          wrapProgram $out/bin/niri \
            --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin" \
            --prefix XDG_DATA_DIRS : "/run/current-system/sw/share" \
            --set NIRI_CONFIG "/etc/niri/config.kdl"
        '';
      };
    in
    {
      environment.etc."niri/config.kdl".source = niriConfig;

      environment.systemPackages = [
        wrappedNiri
        pkgs.xwayland-satellite
      ];

      programs.niri = {
        enable = true;
        package = wrappedNiri;
      };
    };
in
{
  flake.nixosModules.niri = nixosModule;

  perSystem = { pkgs, ... }: {
    packages.niri = pkgs.niri;

    apps.niri = {
      type = "app";
      program = "${pkgs.niri}/bin/niri";
      meta.description = "Scrollable-tiling Wayland compositor";
    };
  };
}
