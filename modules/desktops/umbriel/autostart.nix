{
  flake.modules.homeManager."desktop-umbriel" = {
    pkgs,
    lib,
    config,
    ...
  }: let
    browser = config.home.sessionVariables.BROWSER;
    noctalia = lib.getExe pkgs.noctalia;
  in {
    programs.umbriel.settings.general.autostart = [
      noctalia
      browser
    ];
  };
}
