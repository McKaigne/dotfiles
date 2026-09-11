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

  perSystem = { self', pkgs, ... }: let
    niriConfig = pkgs.writeText "config.kdl" (builtins.replaceStrings
      [
        "@noctaliaShell@"
        "@xwaylandSatellite@"
        "@systemctl@"
        "@whichKey@"
        "@ghostty@"
        "@thunar@"
        "@helium@"
        "@emacsclient@"
        "@grim@"
        "@slurp@"
        "@wlCopy@"
        "@brightnessctl@"
        "@wpctl@"
        "@playerctl@"
      ]
      [
        "${self'.packages.noctalia-shell}/bin/noctalia-shell"
        "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
        "${pkgs.systemd}/bin/systemctl"
        "${self'.packages.wlr-which-key}/bin/wlr-which-key"
        "${self'.packages.ghostty}/bin/ghostty"
        "${self'.packages.thunar}/bin/thunar"
        "${self'.packages.helium}/bin/helium"
        "${self'.packages.emacs}/bin/emacsclient"
        "${pkgs.grim}/bin/grim"
        "${pkgs.slurp}/bin/slurp"
        "${pkgs.wl-clipboard}/bin/wl-copy"
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "${pkgs.wireplumber}/bin/wpctl"
        "${pkgs.playerctl}/bin/playerctl"
      ]
      (builtins.readFile ./config.kdl)
    );
  in {
    packages.niri = pkgs.symlinkJoin {
      name = "niri-wrapped";
      paths = [ pkgs.niri ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = (pkgs.niri.passthru or { }) // {
        providedSessions = [ "niri" ];
      };
      postBuild = ''
        wrapProgram $out/bin/niri \
          --add-flags "--config ${niriConfig}"
      '';
    };

    apps.niri = {
      type = "app";
      program = "${self'.packages.niri}/bin/niri";
      meta.description = "Scrollable-tiling Wayland compositor wrapped with hermetic config";
    };
  };
}