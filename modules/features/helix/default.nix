{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.helix
    ];
  };
in
{
  flake.nixosModules.helix = nixosModule;

  perSystem = { pkgs, lib, ... }:
    let
      noctaliaHelixTheme = pkgs.writeText "noctalia.toml" ''
        inherits = "catppuccin_mocha"
      '';

      helixConfigDir = pkgs.runCommand "helix-config-dir" {} ''
        mkdir -p $out/helix/themes
        cp ${./config.toml} $out/helix/config.toml
        cp ${./languages.toml} $out/helix/languages.toml
        cp ${noctaliaHelixTheme} $out/helix/themes/noctalia.toml
      '';

      wrappedHelix = pkgs.symlinkJoin {
        name = "helix";
        paths = [ pkgs.helix ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/hx \
            --prefix PATH : "${lib.makeBinPath [ pkgs.marksman pkgs.gnused ]}" \
            --prefix XDG_CONFIG_DIRS : "${helixConfigDir}" \
            --add-flags "--config ${./config.toml}"
          [ -e $out/bin/helix ] || ln -sf $out/bin/hx $out/bin/helix
        '';
      };
    in
    {
      packages.helix = wrappedHelix;

      apps.helix = {
        type = "app";
        program = "${wrappedHelix}/bin/hx";
        meta.description = "Hermetically wrapped Helix modal text editor with Marksman LSP";
      };
    };
}