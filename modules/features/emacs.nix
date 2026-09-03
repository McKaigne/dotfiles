
{ self, inputs, ... }: {
  flake.nixosModules.emacs = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs
    ];

    # Auto-start Emacs Daemon in the background
    services.emacs = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myEmacs;
      defaultEditor = true;
    };
  };

  perSystem = { pkgs, lib, ... }:
    let
      llvm = pkgs.llvmPackages_18;

      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        llvm.clang
        llvm.clang-tools
        llvm.lldb
        cmake
        ninja
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
        zig_0_15
      ];

      # Path to C++ standard library headers on NixOS
      cxxHeaders = "${llvm.libcxx}/include/c++/v1";

      myEmacs = pkgs.symlinkJoin {
        name = "my-doom-emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}"

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}"
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
