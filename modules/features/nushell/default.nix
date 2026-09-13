{ self, ... }:

let
  nixosModule = { config, pkgs, ... }: {
    environment.shells = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
    users.users.${config.mainUser}.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.nushell
      pkgs.zoxide
      pkgs.fzf
    ];
  };
in
{
  flake.nixosModules.nushell = nixosModule;

  perSystem = { self', pkgs, lib, ... }: let
    starshipConfig = ./starship.toml;

    starshipInit = pkgs.runCommand "starship-init.nu" {} ''
      STARSHIP_CONFIG=${starshipConfig} ${pkgs.starship}/bin/starship init nu > $out
    '';

    zoxideInit = pkgs.runCommand "zoxide-init.nu" {} ''
      ${pkgs.zoxide}/bin/zoxide init nushell > $out
    '';

    configNu = pkgs.writeText "config.nu" (
      builtins.replaceStrings
        [ "@starshipInit@" "@zoxideInit@" ]
        [ "${starshipInit}" "${zoxideInit}" ]
        (builtins.readFile ./config.nu)
    );

    envNu = ./env.nu;
  in {
    packages.nushell = pkgs.symlinkJoin {
      name = "nushell-wrapped";
      paths = [ pkgs.nushell pkgs.starship pkgs.zoxide pkgs.fzf ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --set STARSHIP_CONFIG "${starshipConfig}" \
          --prefix PATH : "${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf ]}" \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };

    apps.nushell = {
      type = "app";
      program = "${self'.packages.nushell}/bin/nu";
      meta.description = "Hermetically wrapped Nushell with Starship and in-store Zoxide";
    };
  };
}