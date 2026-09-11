{ self, ... }:
let
  nixosModule = { pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.yazi
    ];
  };
in
{
  flake.nixosModules.yazi = nixosModule;

  perSystem = { self', pkgs, ... }:
    let
      yaziToml = pkgs.writeText "yazi.toml" (
        builtins.replaceStrings [ "@helix@" ] [ "${self'.packages.helix}/bin/hx" ] (builtins.readFile ./yazi.toml)
      );

      yaziConfigDir = pkgs.runCommand "yazi-config-dir" {} ''
        mkdir -p $out
        cp ${yaziToml} $out/yazi.toml
      '';

      wrappedYazi = pkgs.symlinkJoin {
        name = "yazi";
        paths = [ pkgs.yazi ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/yazi \
            --set YAZI_CONFIG_HOME "${yaziConfigDir}"
        '';
      };
    in
    {
      packages.yazi = wrappedYazi;

      apps.yazi = {
        type = "app";
        program = "${wrappedYazi}/bin/yazi";
        meta.description = "Hermetically wrapped Yazi file manager";
      };
    };
}