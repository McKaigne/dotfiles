{
  flake.modules.generic."cursor" = {
    lib,
    pkgs,
    ...
  }: {
    options.workstation.cursor = {
      theme = lib.mkOption {
        type = lib.types.str;
        readOnly = true;
        description = "Cursor theme name.";
      };

      package = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        description = "Cursor theme package, also used by the greeter.";
      };
    };

    # Posy's cursor; other variants in the package: Posy_Cursor_Black,
    # Posy_Cursor_Mono, Posy_Cursor_Mono_Black, Posy_Cursor_Strokeless.
    config.workstation.cursor = {
      theme = "Posy_Cursor";
      package = pkgs.posy-cursors;
    };
  };
}
