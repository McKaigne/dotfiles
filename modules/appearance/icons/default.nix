{
  flake.modules.homeManager."icons" = {
    config,
    lib,
    pkgs,
    ...
  }: let
    generateIcons = pkgs.writeShellApplication {
      name = "generate-noctalia-icons";
      runtimeInputs = [pkgs.glib pkgs.gtk3];
      text = ''
        export GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas
        exec ${lib.getExe pkgs.python3} ${./generate-icons.py} \
          --source ${pkgs.gruvbox-plus-icons}/share/icons/Gruvbox-Plus-Dark \
          "$@"
      '';
    };
  in {
    home.packages = [generateIcons];

    # Keep the GTK fallback without resetting Noctalia's live GSettings selection
    # whenever Home Manager activates a generation. The fallback (and Qt, see
    # qt.nix) uses Noctalia-Gruvbox, a link the generator keeps pointing at the
    # current palette; until it has run, it points at the plain theme.
    gtk.gtk3 = {
      iconTheme = null;
      extraConfig.gtk-icon-theme-name = "Noctalia-Gruvbox";
    };
    home.activation.seedNoctaliaIcons = lib.hm.dag.entryAfter ["writeBoundary"] ''
      icons="''${XDG_DATA_HOME:-$HOME/.local/share}/icons"
      if [ ! -e "$icons/Noctalia-Gruvbox" ]; then
        $DRY_RUN_CMD mkdir -p "$icons"
        $DRY_RUN_CMD ln -sfn ${pkgs.gruvbox-plus-icons}/share/icons/${config.gtk.iconTheme.name} "$icons/Noctalia-Gruvbox"
      fi
    '';

    xdg.configFile."noctalia/gruvbox-icons.toml".source = (pkgs.formats.toml {}).generate "gruvbox-icons.toml" {
      theme.templates.user.gruvbox-icons = {
        input_path = "${./templates/gruvbox-icons.json}";
        output_path = "$XDG_CONFIG_HOME/noctalia/gruvbox-icons.json";
        post_hook = ''${lib.getExe generateIcons} "{{ config_dir }}/gruvbox-icons.json"'';
        hook_async = true;
      };
    };
  };
}
