{
  flake.modules.homeManager."btop" = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.packages = [pkgs.btop];

    # btop rewrites btop.conf itself, so seed the two settings instead of owning
    # the file: Noctalia's theme, drawn over the terminal's glass background.
    home.activation.btopGlass = lib.hm.dag.entryAfter ["writeBoundary"] ''
      conf=${lib.escapeShellArg "${config.xdg.configHome}/btop/btop.conf"}
      if [ -z "''${DRY_RUN_CMD:-}" ]; then
        ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$conf")"
        touch "$conf"
        for setting in 'color_theme = "noctalia"' 'theme_background = False'; do
          key=''${setting%% =*}
          if ${pkgs.gnugrep}/bin/grep -q "^$key =" "$conf"; then
            ${pkgs.gnused}/bin/sed -i "s|^$key =.*|$setting|" "$conf"
          else
            echo "$setting" >> "$conf"
          fi
        done
      fi
    '';
  };
}
