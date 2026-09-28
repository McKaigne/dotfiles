{ self, ... }:
let
  nixosModule = { config, pkgs, ... }: {
    environment.shells = [ self.packages.${pkgs.stdenv.hostPlatform.system}.nushell ];
    users.users.${config.mainUser}.shell = self.packages.${pkgs.stdenv.hostPlatform.system}.nushell;
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.nushell
      pkgs.zoxide
      pkgs.fzf
      pkgs.direnv
      pkgs.devenv
      pkgs.carapace
    ];
  };
in
{
  flake.nixosModules.nushell = nixosModule;

  perSystem = { self', pkgs, lib, ... }:
    let
      starshipInit = pkgs.runCommand "starship-init.nu" {} ''
        ${pkgs.starship}/bin/starship init nu > $out
      '';

      zoxideInit = pkgs.runCommand "zoxide-init.nu" {} ''
        ${pkgs.zoxide}/bin/zoxide init nushell > $out
      '';

      carapaceInit = pkgs.runCommand "carapace-init.nu" {} ''
        ${pkgs.carapace}/bin/carapace _carapace nushell > $out
      '';

      configNu = pkgs.writeText "config.nu" (
        builtins.replaceStrings
          [ "@starshipInit@" "@zoxideInit@" "@carapaceInit@" ]
          [ "${starshipInit}" "${zoxideInit}" "${carapaceInit}" ]
          (builtins.readFile ./config.nu)
      );

      envNu = ./env.nu;

      wrappedNushell = pkgs.symlinkJoin {
        name = "nushell-wrapped";
        paths = [
          pkgs.nushell
          pkgs.starship
          pkgs.zoxide
          pkgs.fzf
          pkgs.direnv
          pkgs.devenv
          pkgs.carapace
        ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        passthru = {
          shellPath = "/bin/nu";
        };
        postBuild = ''
          wrapProgram $out/bin/nu \
            --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin:${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf pkgs.direnv pkgs.devenv pkgs.carapace pkgs.nnn pkgs.bottom pkgs.fetch pkgs.yazi ]}" \
            --add-flags "--config ${configNu} --env-config ${envNu}"
        '';
      };
    in
    {
      packages.nushell = wrappedNushell;

      apps.nushell = {
        type = "app";
        program = "${wrappedNushell}/bin/nu";
        meta.description = "Nushell with live dynamic Starship palette syncing";
      };
    };
}
