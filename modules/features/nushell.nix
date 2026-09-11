{ self, ... }:

let
  nixosModule = { config, pkgs, ... }: {
    environment.shells = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
    users.users.${config.mainUser}.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
  };
in
{
  flake.nixosModules.nushell = nixosModule;
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { self', pkgs, lib, ... }: let
    starshipConfig = pkgs.writeText "starship.toml" ''
      add_newline = false
      format = """$directory$character"""
      palette = "catppuccin_mocha"
      right_format = """$all"""
      command_timeout = 1000

      [character]
      vicmd_symbol = "[N] >>>"
      success_symbol = '[➜](bold green)'

      [directory.substitutions]
      '~/tests/starship-custom' = 'work-project'

      [git_branch]
      format = '[$symbol$branch(:$remote_branch)]($style)'

      [aws]
      format = '[$symbol(profile: "$profile" )(\(region: $region\) )]($style)'
      disabled = false
      style = 'bold blue'
      symbol = " "

      [golang]
      format = '[ ](bold cyan)'

      [kubernetes]
      symbol = '☸ '
      disabled = true
      detect_files = ['Dockerfile']
      format = '[$symbol$context( \($namespace\))]($style) '
      contexts = [
        { context_pattern = "arn:aws:eks:us-west-2:577926974532:cluster/zd-pvc-omer", style = "green", context_alias = "omerxx", symbol = " " },
      ]

      [docker_context]
      disabled = true

      [palettes.catppuccin_mocha]
      rosewater = "#f5e0dc"
      flamingo = "#f2cdcd"
      pink = "#f5c2e7"
      mauve = "#cba6f7"
      red = "#f38ba8"
      maroon = "#eba0ac"
      peach = "#fab387"
      yellow = "#f9e2af"
      green = "#a6e3a1"
      teal = "#94e2d5"
      sky = "#89dceb"
      sapphire = "#74c7ec"
      blue = "#89b4fa"
      lavender = "#b4befe"
      text = "#cdd6f4"
      subtext1 = "#bac2de"
      subtext0 = "#a6adc8"
      overlay2 = "#9399b2"
      overlay1 = "#7f849c"
      overlay0 = "#6c7086"
      surface2 = "#585b70"
      surface1 = "#45475a"
      surface0 = "#313244"
      base = "#1e1e2e"
      mantle = "#181825"
      crust = "#11111b"
    '';

    starshipInit = pkgs.runCommand "starship-init.nu" {} ''
      STARSHIP_CONFIG=${starshipConfig} ${pkgs.starship}/bin/starship init nu > $out
    '';

    configNu = pkgs.writeText "config.nu" ''
      $env.config.show_banner = false
      $env.config.edit_mode = 'vi'
      $env.config.cursor_shape = {
        vi_insert: 'block'
        vi_normal: 'block'
        emacs: 'block'
      }

      $env.config.keybindings = (
        $env.config.keybindings? | default [] | append [
          {
            name: delete_one_word_backward
            modifier: control
            keycode: char_w
            mode: [emacs, vi_insert]
            event: { edit: backspaceword }
          }
        ]
      )

      $env.config.abbreviations = {
        nr: "sudo nixos-rebuild switch --flake /etc/nixos#castor"
        nfu: "nix flake update --flake /etc/nixos"
        ncd: "cd /etc/nixos"
        ga: "git add -A"
        gc: "git commit -m"
        gca: "git commit -a -m"
        gp: "git push"
        gpu: "git pull"
        gst: "git status"
        gd: "git diff"
        e: "emacsclient -c -a 'emacs'"
        et: "emacsclient -t -a 'emacs'"
        v: "emacsclient -c -a 'emacs'"
        doom: "doom"
        ds: "doom sync"
        h: "hx"
        hx: "hx"
        "h.": "hx ."
        fm: "thunar"
        y: "yazi"
        t: "tmux"
        ta: "tmux attach"
        tls: "tmux list-sessions"
        tn: "tmux new -s"
        tk: "tmux kill-session -t"
        f: "fetch"
        lt: "eza --tree --level=2 --long --icons --git"
        cat: "bat --paging=never"
      }

      def cx [dir: path] {
        cd $dir
        ls -l
      }

      source ${starshipInit}
    '';

    envNu = pkgs.writeText "env.nu" ''
      $env.STARSHIP_CONFIG = "${starshipConfig}"

      let active_user = ($env.USER? | default "pollux")
      let active_home = ($env.HOME? | default $"/home/($active_user)")

      let system_bins = [
        "/run/wrappers/bin"
        "/run/current-system/sw/bin"
        $"/etc/profiles/per-user/($active_user)/bin"
        $"($active_home)/.nix-profile/bin"
        $"($active_home)/.local/bin"
        $"($active_home)/.cargo/bin"
      ]

      let current_paths = (
        if ($env.PATH? | is-empty) {
          []
        } else if ($env.PATH | describe | str starts-with "list") {
          $env.PATH
        } else {
          $env.PATH | split row (char esep)
        }
      )

      $env.PATH = ($system_bins | append $current_paths | flatten | uniq)
    '';
  in {
    packages.nushell = pkgs.symlinkJoin {
      name = "nushell-wrapped";
      paths = [ pkgs.nushell pkgs.starship ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --set STARSHIP_CONFIG "${starshipConfig}" \
          --prefix PATH : "${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard ]}" \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };

    apps.nushell = {
      type = "app";
      program = "${self'.packages.nushell}/bin/nu";
      meta.description = "Hermetically wrapped Nushell login and interactive shell";
    };
  };
}