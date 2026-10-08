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

        abbreviations: {
          toclip:   "| wl-copy"
          fromclip: "wl-paste"
          silent:   "o+e> /dev/null"
          noerr:    "e> /dev/null"
          savef:    "| save --force "
          savea:    "| save --force --append "

          tojson:   "| to json -i 2"
          fromjson: "| from json"
          toyaml:   "| to yaml"
          fromyaml: "| from yaml"
          tokdl:    "| to kdl"
          fromkdl:  "| from kdl"

          nlaunch:   "noctalia msg panel-toggle launcher"
          ncontrol:  "noctalia msg panel-toggle control-center"
          nsession:  "noctalia msg panel-toggle session"
          nclip:     "noctalia msg panel-toggle clipboard"
          nsettings: "noctalia msg settings-toggle"
          nbar:      "noctalia msg bar-toggle"
          nlock:     "noctalia msg session lock"
          nclosemsg: "noctalia msg notification-clear-active"

          nreload: "niri msg action load-config-file"
          nclose:  "niri msg action close-window"
          nquit:   "niri msg action quit"
          nfocus:  "niri msg action focus-window --id "
          nwins:   "niri msg -j windows | from json"
          nwork:   "niri msg -j workspaces | from json"
          nmon:    "niri msg -j outputs | from json"

          rebuild: "sudo nixos-rebuild switch --flake /etc/nixos"
          nr:      "sudo nixos-rebuild switch --flake /etc/nixos"
          nboot:   "sudo nixos-rebuild boot --flake /etc/nixos"
          ntest:   "sudo nixos-rebuild test --flake /etc/nixos"
          ncd:     "cd /etc/nixos"
          nupdate: "nix flake update --flake /etc/nixos"
          nclean:  "nix-collect-garbage -d"
          ntry:    "nix run nixpkgs#"
          nshell:  "nix shell nixpkgs#"
          ntrace:  "--show-trace"

          ga:       "git add -A"
          gstage:   "git add -A"
          gpatch:   "git add -p"
          gundo:    "git reset --soft HEAD~1"
          gunstage: "git restore --staged ."
          gwipe:    "git reset --hard HEAD"
          gamend:   "git commit --amend --no-edit"
          gst:      "git status"
          gc:       "git commit -m \"\""
          gdiff:    "git diff"
          gdiffs:   "git diff --staged"
          gp:       "git push"
          gpushf:   "git push --force-with-lease"
          gpl:      "git pull"
          glg:      "git log --oneline --graph -n 20"
          gbranch:  "git switch "
          gnew:     "git switch -c "

          zj:    "zellij"
          zja:   "zellij attach "
          zjl:   "zellij list-sessions"
          zjk:   "zellij kill-session "
          zjka:  "zellij kill-all-sessions"

          zq:    "zoxide query "
          zql:   "zoxide query -l"
          za:    "zoxide add "
          zr:    "zoxide remove "

          hxf: "nvim /etc/nixos/flake.nix"
          hxh: "nvim /etc/nixos/modules/hosts/hyde/default.nix"
          hxc: "nvim /etc/nixos/modules/shared/core.nix"
          hxn: "nvim /etc/nixos/modules/features/terminal/shell.nix"
          hxi: "nvim /etc/nixos/modules/features/desktop/config.kdl"
          hxz: "nvim /etc/nixos/modules/features/terminal/zellij.nix"
        }
      }

      def sync-noctalia [] {
        let src = ($env.HOME | path join ".config/noctalia/settings.json")
        let dest = "/etc/nixos/modules/features/desktop/noctalia.json"
        if ($src | path exists) {
          cp -f $src $dest
          print $"Successfully synced ($src) -> ($dest)"
        } else {
          print $"Error: ($src) does not exist."
        }
      }

      def fkill [] {
        let selected = (ps | select pid name cpu mem | to text | lines | skip 1 | ^fzf --header="Select process to kill (ESC to cancel)")
        if ($selected | is-not-empty) {
          let pid = ($selected | split row " " | where { |x| $x != "" } | get 0 | into int)
          kill -9 $pid
          print $"Killed process ($pid)"
        }
      }

      def get-config-files [path: string] {
        let target = ($path | path expand)
        let extensions = [
          "-e" "nix" "-e" "kdl" "-e" "toml" "-e" "conf" "-e" "ini" "-e" "el" "-e" "json" "-e" "nu" "-e" "py" "-e" "css" "-e" "lua"
        ]
        let excludes = [
          "-E" ".git" "-E" "flake.lock" "-E" "node_modules" "-E" "target" "-E" "result"
          "-E" "*cache*" "-E" "*Cache*" "-E" "*.log" "-E" "*.sqlite*" "-E" "*.db*"
        ]
        ^fd . $target -t f -L -H -S -50k ...$extensions ...$excludes | lines
      }

      def cft [path: string = "."] {
        let files = (get-config-files $path)
        if ($files | is-empty) {
          print $"No configuration files found in ($path)"
          return
        }
        let tree_out = ($files | str join (char nl) | tree -a -F --fromfile)
        $tree_out | wl-copy
        print $tree_out
        print $"\n[Copied tree of ($files | length) core config files to clipboard]"
      }

      def cfb [path: string = "."] {
        let files = (get-config-files $path)
        if ($files | is-empty) {
          print $"No configuration files found in ($path)"
          return
        }
        let content = ($files | each { |f| bat --style=header,grid --paging=never $f } | str join (char nl))
        $content | wl-copy
        print $"[Copied full content of ($files | length) config files to clipboard]"
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
      alias f = ^fetch
      alias fetch = ^fetch
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
          --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin:${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf pkgs.direnv pkgs.carapace pkgs.btop pkgs.yazi pkgs.jq pkgs.git pkgs.tree pkgs.bat pkgs.fd ]}" \
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
