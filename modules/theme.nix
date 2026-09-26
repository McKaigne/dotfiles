
{ self, ... }:
let
  themeModule = { config, pkgs, lib, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.bibata-cursors-fixed
      pkgs.adw-gtk3
      pkgs.papirus-icon-theme
    ];

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    environment.sessionVariables = {
      XCURSOR_THEME  = "Bibata-Modern-Classic";
      XCURSOR_SIZE   = "16";
      NIXOS_OZONE_WL = "1";
      GTK_THEME      = "adw-gtk3-dark";
    };
  };
in
{
  flake.nixosModules.theme = themeModule;

  perSystem = { pkgs, ... }: {
    packages.bibata-cursors-fixed = pkgs.runCommand "bibata-modern-classic-fixed" { } ''
      mkdir -p $out/share/icons
      cp -r ${pkgs.bibata-cursors}/share/icons/Bibata-Modern-Classic $out/share/icons/Bibata-Modern-Classic
      chmod -R u+w $out/share/icons/Bibata-Modern-Classic
      cd $out/share/icons/Bibata-Modern-Classic/cursors
      [ -e hand2 ] || ln -sf pointer hand2
      [ -e sb_v_double_arrow ] || ln -sf ns-resize sb_v_double_arrow
      [ -e sb_h_double_arrow ] || ln -sf ew-resize sb_h_double_arrow
    '';
  };
}
