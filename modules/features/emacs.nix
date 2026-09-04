
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
      llvm = pkgs.llvmPackages_18;
      cxxHeaders = "${llvm.libcxx}/include/c++/v1";
      iconPath = "/run/current-system/sw/share/icons:/home/pollux/.icons:/home/pollux/.local/share/icons";

      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        llvm.clang-tools
        cmake
        ninja
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
        zig_0_15
        bibata-cursors
        glib # provides gsettings
      ];

      myEmacs = pkgs.symlinkJoin {
        name = "emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}"

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}"
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
