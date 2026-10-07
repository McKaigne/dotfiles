{ config, pkgs, lib, ... }:
let
  user = config.mainUser;

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
        --prefix PATH : "/run/wrappers/bin:/run/current-system/sw/bin:${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf pkgs.direnv pkgs.devenv pkgs.carapace pkgs.nnn pkgs.btop pkgs.fetch pkgs.yazi ]}" \
        --set STARSHIP_CONFIG "/etc/starship.toml" \
        --add-flags "--config ${configNu} --env-config ${envNu}"
    '';
  };
in
{
  environment.shells = [ wrappedNushell ];
  users.users.${user}.shell = wrappedNushell;

  environment.systemPackages = [
    wrappedNushell
    pkgs.starship
    pkgs.zoxide
    pkgs.fzf
    pkgs.direnv
    pkgs.devenv
    pkgs.carapace
  ];

  environment.sessionVariables = {
    STARSHIP_CONFIG = "/etc/starship.toml";
  };

  environment.etc."starship.toml".source = ./starship.toml;
}
