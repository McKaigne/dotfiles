{ self, inputs, ... }: {
  flake.nixosModules.helium = { pkgs, lib, ... }:
    let
      rawHelium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
      wrappedHelium = pkgs.symlinkJoin {
        name = "helium";
        paths = [ rawHelium ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/helium \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${pkgs.bibata-cursors}/share/icons:/run/current-system/sw/share/icons" \
            --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.bibata-cursors}/share:/run/current-system/sw/share" \
            --add-flags "--ozone-platform=wayland"
        '';
      };
    in
    {
      environment.systemPackages = [ wrappedHelium ];
    };
}