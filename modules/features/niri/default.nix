{ self, ... }:

let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.niri
      pkgs.xwayland-satellite
    ];
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };
in
{
  flake.nixosModules.niri = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, ... }:
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

      niriConfig = pkgs.writeText "config.kdl" (builtins.replaceStrings
        [
          "@noctaliaShell@"
          "@xwaylandSatellite@"
          "@systemctl@"
          "@ghostty@"
          "@superfile@"
          "@helium@"
          "@wpctl@"
          "@playerctl@"
          "@cliamp@"
          "@tmuxSessionizer@"
          "@helixTmuxFocus@"
          "@tmuxTermFocus@"
          "@lazygit@"
          "@emacsclient@"
          "@easyeffects@"
          "@pavucontrol@"
          "@screenshotArea@"
          "@screenshotFull@"
          "@brightnessUp@"
          "@brightnessDown@"
        ]
        [
          "${self'.packages.noctalia-shell}/bin/noctalia-shell"
          "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
          "${pkgs.systemd}/bin/systemctl"
          "${self'.packages.ghostty}/bin/ghostty"
          "${self'.packages.superfile}/bin/superfile"
          "${self'.packages.helium}/bin/helium"
          "${pkgs.wireplumber}/bin/wpctl"
          "${pkgs.playerctl}/bin/playerctl"
          "${self'.packages.cliamp}/bin/cliamp"
          "${self'.packages.tmux-sessionizer}/bin/tmux-sessionizer"
          "${self'.packages.helix-tmux-focus}/bin/helix-tmux-focus"
          "${self'.packages.tmux-term-focus}/bin/tmux-term-focus"
          "${pkgs.lazygit}/bin/lazygit"
          "${self'.packages.emacs}/bin/emacsclient"
          "${self'.packages.easyeffects}/bin/easyeffects"
          "${pkgs.pavucontrol}/bin/pavucontrol"
          "${screenshotArea}/bin/screenshot-area"
          "${screenshotFull}/bin/screenshot-full"
          "${brightnessUp}/bin/brightness-up"
          "${brightnessDown}/bin/brightness-down"
        ]
        (builtins.readFile ./config.kdl)
      );
    in
    {
      packages.niri = pkgs.symlinkJoin {
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
            --set NIRI_CONFIG "${niriConfig}"
        '';
      };

      apps.niri = {
        type = "app";
        program = "${self'.packages.niri}/bin/niri";
        meta.description = "Scrollable-tiling Wayland compositor wrapped with hermetic config";
      };
    };
}