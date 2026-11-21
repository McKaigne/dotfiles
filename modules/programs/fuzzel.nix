{
  flake.modules.homeManager.fuzzel =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      fuzzelColors = "${config.xdg.configHome}/fuzzel/noctalia.ini";
    in
    {
      home.packages = [ pkgs.fuzzel ];

      xdg.configFile."fuzzel/fuzzel.ini" = {
        text = ''
          include=${fuzzelColors}

          [main]
          font=EB Garamond:size=14
          prompt="➜ "
          lines=12
          width=35
          horizontal-pad=20
          vertical-pad=15
          inner-pad=10

          [border]
          width=2
          radius=4
        '';
        force = true;
      };

      home.activation.seedFuzzelColors = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        colors=${lib.escapeShellArg fuzzelColors}
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$(dirname "$colors")"
        if [ ! -f "$colors" ] && [ -z "''${DRY_RUN_CMD:-}" ]; then
          printf '[colors]\nbackground=1e1e2eff\ntext=cdd6f4ff\n' > "$colors"
        fi
      '';
    };
}
