{ self, ... }:

let
  nixosModule = { config, pkgs, ... }: {
    environment.shells = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
    users.users.${config.mainUser}.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
    environment.systemPackages = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
  };
in
{
  flake.nixosModules.nushell = nixosModule;

  perSystem = { self', pkgs, lib, ... }: let
    starshipConfig = ./starship.toml;

    starshipInit = pkgs.runCommand "starship-init.nu" {} ''
      STARSHIP_CONFIG=${starshipConfig} ${pkgs.starship}/bin/starship init nu > $out
    '';

    configNu = pkgs.writeText "config.nu" (
      builtins.replaceStrings [ "@starshipInit@" ] [ "${starshipInit}" ] (builtins.readFile ./config.nu)
    );

    envNu = ./env.nu;
  in {
    packages.nushell = pkgs.symlinkJoin {
      name = "nushell-wrapped";
      paths = [ pkgs.nushell pkgs.starship ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --set STARSHIP_CONFIG "${starshipConfig}" \
          --prefix PATH : "${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard ]}" \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };

    apps.nushell = {
      type = "app";
      program = "${self'.packages.nushell}/bin/nu";
      meta.description = "Hermetically wrapped Nushell login and interactive shell";
    };
  };
}