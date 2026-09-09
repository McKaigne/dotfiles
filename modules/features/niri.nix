{ inputs, self, ... }:
{
  flake.nixosModules.niri = { pkgs, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.niri;
    };
  };

  perSystem = { pkgs, self', lib, ... }:
    let
      niriRuntimeDeps = with pkgs; [
        xwayland-satellite
        self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia-shell
        grim
        slurp
        wl-clipboard
        brightnessctl
        playerctl
        hyprlock
      ];

      wrappedNiri = pkgs.symlinkJoin {
        name = "niri";
        paths = [ pkgs.niri ];
        buildInputs = [ pkgs.makeWrapper ];
        passthru = {
          providedSessions = [ "niri" ];
        };
        postBuild = ''
          wrapProgram $out/bin/niri \
            --prefix PATH : ${lib.makeBinPath niriRuntimeDeps}
        '';
      };
    in
    {
      packages.niri = wrappedNiri;
      packages.default = wrappedNiri;

      apps.niri = {
        type = "app";
        program = "${wrappedNiri}/bin/niri";
        meta.description = "Niri scrollable-tiling Wayland compositor";
      };

      apps.default = {
        type = "app";
        program = "${wrappedNiri}/bin/niri";
        meta.description = "Default session (Niri)";
      };
    };
}