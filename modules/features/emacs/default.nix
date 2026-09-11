{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.emacs
    ];

    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.emacs;
      defaultEditor = true;
    };
  };
in
{
  flake.nixosModules.emacs = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      glibcHeaders = "${pkgs.glibc.dev}/include";
      fixedCursor = self'.packages.bibata-cursors-fixed;
      iconPath = "${fixedCursor}/share/icons:/run/current-system/sw/share/icons";

      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        gcc
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
        glib
        self'.packages.nushell
        fixedCursor
      ];

      doomDir = ./doom;

      doomCliScript = pkgs.writeShellScriptBin "doom" ''
        set -eo pipefail
        export PATH="${lib.makeBinPath doomRuntimeDeps}:$PATH"
        export CPATH="${glibcHeaders}''${CPATH:+:$CPATH}"
        export DOOMDIR="''${DOOMDIR:-${doomDir}}"
        export EMACSDIR="''${EMACSDIR:-$HOME/.config/emacs}"

        if [ ! -d "$EMACSDIR" ]; then
          echo "❄ [Doom Emacs] Core not found: bootstrapping Doom repository to $EMACSDIR..."
          ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACSDIR"
          "$EMACSDIR/bin/doom" install --no-config --no-env
        fi

        exec "$EMACSDIR/bin/doom" "$@"
      '';

      myEmacs = pkgs.symlinkJoin {
        name = "emacs";
        paths = [ pkgs.emacs-pgtk doomCliScript ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPATH : "${glibcHeaders}" \
            --set-default DOOMDIR "${doomDir}" \
            --set-default EMACSDIR "$HOME/.config/emacs" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}" \
            --run '
              EMACSDIR="''${EMACSDIR:-$HOME/.config/emacs}"
              if [ ! -f "$EMACSDIR/early-init.el" ]; then
                echo "❄ [Doom Emacs] Bootstrapping Doom core framework into $EMACSDIR..."
                ${pkgs.git}/bin/git clone --depth 1 https://github.com/doomemacs/doomemacs "$EMACSDIR"
                DOOMDIR="''${DOOMDIR:-${doomDir}}" "$EMACSDIR/bin/doom" sync
              fi
            '

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPATH : "${glibcHeaders}" \
            --set-default DOOMDIR "${doomDir}" \
            --set-default EMACSDIR "$HOME/.config/emacs" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}"
        '';
      };
    in
    {
      packages.emacs = myEmacs;
      packages.myEmacs = myEmacs;
      packages.doom = doomCliScript;

      apps.emacs = {
        type = "app";
        program = "${myEmacs}/bin/emacs";
        meta.description = "Doom Emacs wrapped with core build tools, git, and in-store DOOMDIR";
      };

      apps.doom = {
        type = "app";
        program = "${doomCliScript}/bin/doom";
        meta.description = "Doom Emacs CLI manager wrapped with runtime dependencies and in-store DOOMDIR";
      };
    };
}