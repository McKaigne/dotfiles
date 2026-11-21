{
  flake.modules.homeManager."desktop-umbriel" = {...}: {
    programs.umbriel = {
      settings.include.optional.files = [
        # noctalia.toml last, so theme colors win; its template hook expects this order.
        "bibata-cursor.toml"
        "noctalia.toml"
      ];
    };
  };
}
