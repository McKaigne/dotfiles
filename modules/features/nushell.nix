{ self, ... }:

{
  perSystem = { self', pkgs, ... }: let
    configNu = pkgs.writeText "config.nu" ''
      $env.config = {
        show_banner: false
        edit_mode: 'vi'
        cursor_shape: {
          vi_insert: 'block'
          vi_normal: 'block'
          emacs: 'block'
        }
      }

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
        ff: "fastfetch"
        lt: "eza --tree --level=2 --long --icons --git"
        cat: "bat --paging=never"
      }

      def cx [dir: path] {
        cd $dir
        ls -l
      }
    '';

    envNu = pkgs.writeText "env.nu" ''
      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | prepend "/run/wrappers/bin"
        | prepend "/run/current-system/sw/bin"
        | uniq
      )
    '';
  in {
    packages.nushell = pkgs.symlinkJoin {
      name = "nushell-wrapped";
      paths = [ pkgs.nushell ];
      buildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };

    apps.nushell = {
      type = "app";
      program = "${self'.packages.nushell}/bin/nu";
      meta.description = "Hermetically wrapped Nushell login and interactive shell";
    };
  };

  flake.nixosModules.nushell = { config, pkgs, ... }: {
    environment.shells = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
    users.users.${config.mainUser}.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
  };

  flake.nixosModules.castorConfiguration = { ... }: {
    imports = [ self.nixosModules.nushell ];
  };
}