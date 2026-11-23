{config, ...}: let
  flakeConfig = config;
in {
  flake.modules.nixos.onlyoffice = {pkgs, ...}: {
    home-manager.sharedModules = [
      flakeConfig.flake.modules.homeManager.onlyoffice
    ];
    environment.systemPackages = [pkgs.onlyoffice-desktopeditors];
  };

  # The interface in Noctalia's colours: Noctalia renders the theme into
  # OnlyOffice's own themes folder, which it reads at startup, and
  # UITheme names that file (a local theme is selected by file, not id).
  flake.modules.homeManager.onlyoffice = {
    lib,
    pkgs,
    ...
  }: {
    xdg.configFile."onlyoffice/DesktopEditors.conf" = {
      text = ''
        [General]
        UITheme=noctalia.json
      '';
      force = false;
    };

    xdg.configFile."noctalia/onlyoffice.toml".source =
      (pkgs.formats.toml {}).generate "onlyoffice-template.toml"
      {
        theme.templates.user.onlyoffice = {
          input_path = "${./noctalia/templates/onlyoffice.json}";
          output_path = "~/.local/share/onlyoffice/desktopeditors/uithemes/noctalia.json";
        };
      };

    home.activation.onlyofficeThemes = lib.hm.dag.entryAfter ["writeBoundary"] ''
      $DRY_RUN_CMD mkdir -p "$HOME/.local/share/onlyoffice/desktopeditors/uithemes"
    '';
  };
}
