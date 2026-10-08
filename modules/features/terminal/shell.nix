{ self, inputs, ... }: {
  flake.nixosModules.shell = { config, pkgs, lib, ... }:
  let
    user = config.mainUser;

    starshipInit = pkgs.runCommand "starship-init.nu" {} ''
      ${pkgs.starship}/bin/starship init nu > $out
    '';

    zoxideInit = pkgs.runCommand "zoxide-init.nu" {} ''
      ${pkgs.zoxide}/bin/zoxide init nushell > $out
    '';

    carapaceInit = pkgs.runCommand "carapace-init.nu" {} ''
      ${pkgs.carapace}/bin/carapace _carapace nushell > $out
    '';

    configNu = pkgs.writeText "config.nu" ''
      $env.config = {
        show_banner: false
        edit_mode: 'vi'
        cursor_shape: {
          vi_insert: 'line'
          vi_normal: 'block'
        }
        table: {
          mode: 'rounded'
          index_mode: 'always'
        }
        hooks: {
          pre_prompt: [{ ||
            if (which direnv | is-not-empty) {
              direnv export json | from json | default {} | load-env
            }
          }]
        }
      }

      alias l = ls
      alias ll = ls -l
      alias la = ls -a
      alias v = nvim
      alias vi = nvim
      alias vim = nvim
      alias hx = helix
      alias bottom = btop
      alias btm = btop
      alias y = yazi
      alias g = git
      alias lg = lazygit
      alias music = cliamp
      alias amp = cliamp

      source "${starshipInit}"
      source "${zoxideInit}"
      source "${carapaceInit}"
    '';

    envNu = pkgs.writeText "env.nu" ''
      $env.STARSHIP_SHELL = "nu"
      $env.STARSHIP_CONFIG = "/etc/starship.toml"

      let nix_paths = [
        "/run/wrappers/bin"
        ($env.HOME? | default "~" | path expand | path join ".nix-profile/bin")
        "/run/current-system/sw/bin"
      ] | where { |p| ($p | is-not-empty) and ($p | path exists) }

      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | prepend $nix_paths
        | uniq
      )
    '';

    wrappedNushell = pkgs.symlinkJoin {
      name = "nushell-wrapped";
      paths = [
        pkgs.nushell
        pkgs.starship
        pkgs.zoxide
        pkgs.fzf
        pkgs.direnv
        pkgs.carapace
      ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin:${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf pkgs.direnv pkgs.carapace pkgs.btop pkgs.yazi pkgs.jq pkgs.git ]}" \
          --set STARSHIP_CONFIG "/etc/starship.toml" \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };
  in
  {
    environment.shells = [ wrappedNushell ];
    users.users.${user}.shell = wrappedNushell;

    environment.systemPackages = [
      wrappedNushell
      pkgs.starship
      pkgs.zoxide
      pkgs.fzf
      pkgs.direnv
      pkgs.carapace
    ];

    environment.sessionVariables = {
      STARSHIP_CONFIG = "/etc/starship.toml";
    };

    environment.etc."starship.toml".source = ./starship.toml;
  };
}
