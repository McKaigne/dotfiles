
{ self, inputs, ... }: {
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs
    ];

    # Auto-start Emacs Daemon in the background on user login
    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs;
      defaultEditor = true;
    };
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
        zig_0_15
      ];

      myEmacs = pkgs.symlinkJoin {
        name = "my-doom-emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --set CASTOR_CLANGXX "${pkgs.clang}/bin/clang++"

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --set CASTOR_CLANGXX "${pkgs.clang}/bin/clang++"
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
