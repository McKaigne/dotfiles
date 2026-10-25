{ self, inputs, ... }: {
  flake.nixosModules.xonsh =
    { config, pkgs, lib, ... }:
    let
      user = config.mainUser;
      # Simple aliases for Xonsh
      isCompound = cmd: lib.hasInfix "&&" cmd || lib.hasInfix ";" cmd || lib.hasPrefix "-" cmd;
      simpleAliases = lib.filterAttrs (_: cmd: !isCompound cmd) config.workstation.shellAliases;
      aliasLines = lib.concatStringsSep "\n" (
        lib.mapAttrsToList (k: v: "aliases['${k}'] = '${v}'") simpleAliases
      );
    in
    {
      environment.systemPackages = [ pkgs.xonsh ];

      home-manager.users.${user} = {
        xdg.configFile."xonsh/rc.xsh" = {
          text = ''
            import os
            import json
            import subprocess

            $STARSHIP_CONFIG = "/etc/starship.toml"
            $EDITOR = "hx"
            $VISUAL = "hx"
            $BAT_THEME = "Catppuccin Mocha"

            $PATH.insert(0, os.path.expanduser("~/.local/bin"))
            $PATH.insert(0, os.path.expanduser("~/.cargo/bin"))

            # Simple Aliases
            ${aliasLines}

            # Starship Prompt Integration (Official Xonsh syntax)
            execx($(${pkgs.starship}/bin/starship init xonsh))

            # Zoxide Integration (Official Xonsh syntax)
            execx($(${pkgs.zoxide}/bin/zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')

            # Lightweight Direnv on_chdir Hook for Xonsh
            @events.on_chdir
            def _direnv_hook(olddir, newdir, **kwargs):
                try:
                    res = subprocess.run(['direnv', 'export', 'json'], capture_output=True, text=True)
                    if res.returncode == 0 and res.stdout.strip():
                        data = json.loads(res.stdout)
                        for k, v in data.items():
                            if v is None:
                                __xonsh__.env.pop(k, None)
                            else:
                                __xonsh__.env[k] = v
                except Exception:
                    pass
          '';
          force = true;
        };
      };
    };
}
