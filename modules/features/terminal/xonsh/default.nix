{ self, inputs, ... }: {
  flake.nixosModules.xonsh =
    { config, pkgs, lib, ... }:
    let
      user = config.mainUser;
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
            $EDITOR = "nvim"
            $VISUAL = "nvim"
            $BAT_THEME = "Catppuccin Mocha"

            $PATH.insert(0, os.path.expanduser("~/.local/bin"))
            $PATH.insert(0, os.path.expanduser("~/.cargo/bin"))

            # Starship Prompt Integration
            execx($(${pkgs.starship}/bin/starship init xonsh))

            # Zoxide Integration
            execx($(${pkgs.zoxide}/bin/zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')

            # Direnv hook for Xonsh
            def _direnv_hook(olddir=None, newdir=None, **kwargs):
                try:
                    res = subprocess.run(['${pkgs.direnv}/bin/direnv', 'export', 'json'], capture_output=True, text=True)
                    if res.returncode == 0 and res.stdout.strip():
                        data = json.loads(res.stdout)
                        for k, v in data.items():
                            if v is None:
                                __xonsh__.env.pop(k, None)
                            else:
                                __xonsh__.env[k] = v
                except Exception:
                    pass

            @events.on_chdir
            def _direnv_chdir(olddir, newdir, **kwargs):
                _direnv_hook(olddir, newdir, **kwargs)

            # Evaluate direnv on initial session launch
            _direnv_hook()
          '';
          force = true;
        };
      };
    };
}
