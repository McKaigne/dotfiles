{ self, inputs, ... }: {
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs
    ];
  };

  perSystem = { pkgs, lib, ... }:
    let
      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        clang
        clang-tools
        cmake
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
        # Exact Zig version required by Ghostel / libghostty-vt
        zig_0_15
      ];

      myEmacs = pkgs.symlinkJoin {
        name = "my-doom-emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps}

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps}
        '';
      };
    in
    {
      packages.myEmacs = myEmacs;
      packages.default = myEmacs;
      apps.default = {
        type = "app";
        program = "${myEmacs}/bin/emacs";
      };
    };
}
