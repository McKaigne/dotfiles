{ self, inputs, ... }: {
  # 1. NixOS System Module (hooks the wrapped package into your OS)
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs
    ];
  };

  # 2. Per-System Package Wrapper (Allows running with `nix run`)
  perSystem = { pkgs, lib, ... }:
    let
      # Tools required by Doom Emacs & Language Servers
      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        clang
        clang-tools # clangd for C++ LSP
        cmake
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
      ];

      # Store path of your Doom config folder
      doomConfigDir = ./doom;

      # Wrapped Emacs binary with dependencies & config baked in
      myEmacs = pkgs.symlinkJoin {
        name = "my-doom-emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --set-default DOOMDIR "${doomConfigDir}"

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps}
        '';
      };
    in
    {
      # Exported package: `nix run .#myEmacs`
      packages.myEmacs = myEmacs;

      # Default package & app: `nix run`
      packages.default = myEmacs;
      apps.default = {
        type = "app";
        program = "${myEmacs}/bin/emacs";
      };
    };
}
