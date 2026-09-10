{ self, inputs, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helium
    ];
  };
in
{
  flake.nixosModules.helium = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }:
    let
      rawHelium = inputs.helium.packages.${pkgs.stdenv.hostPlatform.system}.default;
      schemaDir = "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}/glib-2.0/schemas";
      fixedCursor = self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-fixed;
      wrappedHelium = pkgs.symlinkJoin {
        name = "helium";
        paths = [ rawHelium ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/helium \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${fixedCursor}/share/icons:/run/current-system/sw/share/icons" \
            --prefix GSETTINGS_SCHEMA_DIR : "${schemaDir}" \
            --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share:${pkgs.gtk3}/share:${pkgs.adwaita-icon-theme}/share:${fixedCursor}/share:/run/current-system/sw/share" \
            --set-default XDG_CURRENT_DESKTOP "GNOME" \
            --add-flags "--ozone-platform=wayland" \
            --add-flags "--gtk-version=3"
        '';
      };
    in
    {
      packages.helium = wrappedHelium;

      apps.helium = {
        type = "app";
        program = "${wrappedHelium}/bin/helium";
        meta.description = "Hermetically wrapped Helium Wayland browser";
      };
    };
}