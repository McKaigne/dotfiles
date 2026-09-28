{ self, inputs, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.cliamp
    ];
  };
in
{
  flake.nixosModules.cliamp = nixosModule;

  perSystem = { pkgs, lib, system, ... }:
    let
      rawCliamp = inputs.cliamp.packages.${system}.default;
      wrappedCliamp = pkgs.symlinkJoin {
        name = "cliamp";
        paths = [ rawCliamp ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/cliamp \
            --prefix PATH : "${lib.makeBinPath [ pkgs.ffmpeg pkgs.yt-dlp ]}"
        '';
      };
    in
    {
      packages.cliamp = wrappedCliamp;

      apps.cliamp = {
        type = "app";
        program = "${wrappedCliamp}/bin/cliamp";
        meta.description = "Terminal music player with YouTube Music engine";
      };
    };
}
