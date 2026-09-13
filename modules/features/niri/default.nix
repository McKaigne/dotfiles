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
        "@loginctl@"
        "@ghostty@"
        "@thunar@"
        "@helium@"
        "@emacsclient@"
        "@zed@"
        "@grim@"
        "@slurp@"
        "@wlCopy@"
        "@brightnessctl@"
        "@wpctl@"
        "@playerctl@"
        "@niri@"
        "@jq@"
        "@wlsunset@"
        "@localsend@"
        "@btop@"
        "@qalculate@"
        "@fuzzel@"
      ]
      [
        "${self'.packages.noctalia-shell}/bin/noctalia-shell"
        "${pkgs.xwayland-satellite}/bin/xwayland-satellite"
        "${pkgs.systemd}/bin/systemctl"
        "${pkgs.systemd}/bin/loginctl"
        "${self'.packages.ghostty}/bin/ghostty"
        "${self'.packages.thunar}/bin/thunar"
        "${self'.packages.helium}/bin/helium"
        "${self'.packages.emacs}/bin/emacsclient"
        "${self'.packages.zed}/bin/zed"
        "${pkgs.grim}/bin/grim"
        "${pkgs.slurp}/bin/slurp"
        "${pkgs.wl-clipboard}/bin/wl-copy"
        "${pkgs.brightnessctl}/bin/brightnessctl"
        "${pkgs.wireplumber}/bin/wpctl"
        "${pkgs.playerctl}/bin/playerctl"
        "${pkgs.niri}/bin/niri"
        "${pkgs.jq}/bin/jq"
        "${pkgs.wlsunset}/bin/wlsunset"
        "${pkgs.localsend}/bin/localsend"
        "${self'.packages.btop}/bin/btop"
        "${pkgs.qalculate-gtk}/bin/qalculate-gtk"
        "${self'.packages.fuzzel}/bin/fuzzel"
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
          --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin" \
          --prefix XDG_DATA_DIRS : "/run/current-system/sw/share" \
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