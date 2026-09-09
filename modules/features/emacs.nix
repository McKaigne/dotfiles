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
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      llvm = pkgs.llvmPackages_18;
      cxxHeaders = "${llvm.libcxx}/include/c++/v1";
      iconPath = "${pkgs.bibata-cursors}/share/icons:/run/current-system/sw/share/icons";

      doomRuntimeDeps = with pkgs; [
        git
        ripgrep
        fd
        gcc
        llvm.clang-tools
        cmake
        ninja
        gnumake
        nixfmt
        shellcheck
        python3
        direnv
        zig_0_16
        bibata-cursors
        glib
      ];

      doomDir = ./emacs/doom;

      myEmacs = pkgs.symlinkJoin {
        name = "emacs";
        paths = [ pkgs.emacs-pgtk ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/emacs \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}" \
            --set-default DOOMDIR "${doomDir}" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}"

          wrapProgram $out/bin/emacsclient \
            --prefix PATH : ${lib.makeBinPath doomRuntimeDeps} \
            --prefix CPLUS_INCLUDE_PATH : "${cxxHeaders}" \
            --prefix CPATH : "${cxxHeaders}" \
            --set-default DOOMDIR "${doomDir}" \
            --set XCURSOR_THEME "Bibata-Modern-Classic" \
            --set XCURSOR_SIZE "16" \
            --prefix XCURSOR_PATH : "${iconPath}"
        '';
      };
    in
    {
      packages.emacs = myEmacs;
      packages.myEmacs = myEmacs;

      apps.emacs = {
        type = "app";
        program = "${myEmacs}/bin/emacs";
        meta.description = "Doom Emacs wrapped with build tools, LSP servers, and in-store DOOMDIR";
      };
    };
}