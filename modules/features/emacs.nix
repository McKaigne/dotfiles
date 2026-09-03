
{ self, inputs, ... }: {
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs
    ];

    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs;
      defaultEditor = true;
    };
  };

  perSystem = { pkgs, lib, ... }:
    let
      # Use the wrapped clang-tools package specifically for clangd
      wrappedClangTools = pkgs.clang-tools;

      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        wrappedClangTools  # <-- Contains the wrapped clangd with Nix headers
        cmake
        ninja
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
