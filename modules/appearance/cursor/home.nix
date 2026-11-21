{
  flake.modules.homeManager."cursor" = {
    config,
    pkgs,
    ...
  }: let
    inherit (config.workstation.cursor) package theme;

    defaultIndex = pkgs.writeText "cursor-index.theme" ''
      [Icon Theme]
      Name=Default
      Inherits=${theme}
    '';
  in {
    home.sessionVariables = {
      XCURSOR_SIZE = "24";
      XCURSOR_THEME = theme;
    };

    home.file.".icons/default/index.theme".source = defaultIndex;

    gtk.cursorTheme = {
      inherit package;
      name = theme;
      size = 24;
    };

    xdg.dataFile."icons/default/index.theme".source = defaultIndex;

    xresources.properties = {
      "Xcursor.theme" = theme;
      "Xcursor.size" = 24;
    };
  };
}
