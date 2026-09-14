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

    noctaliaStarshipSync = pkgs.writeShellScriptBin "noctalia-starship-sync" ''
      set -euo pipefail
      CACHE_DIR="$HOME/.cache/noctalia"
      PALETTE_FILE="$CACHE_DIR/starship-palette.toml"
      OUT_FILE="$CACHE_DIR/starship.toml"

      if [ -f "$PALETTE_FILE" ]; then
        mkdir -p "$CACHE_DIR"
        ${pkgs.gnused}/bin/sed '/\[palettes\.noctalia\]/,$d' "${starshipConfig}" > "$OUT_FILE"
        cat "$PALETTE_FILE" >> "$OUT_FILE"
      fi
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
      paths = [ pkgs.nushell pkgs.starship pkgs.zoxide pkgs.fzf noctaliaStarshipSync ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      passthru = {
        shellPath = "/bin/nu";
      };
      postBuild = ''
        wrapProgram $out/bin/nu \
          --set STARSHIP_CONFIG "${starshipConfig}" \
          --prefix PATH : "${lib.makeBinPath [ pkgs.starship pkgs.wl-clipboard pkgs.zoxide pkgs.fzf noctaliaStarshipSync ]}" \
          --add-flags "--config ${configNu} --env-config ${envNu}"
      '';
    };

    packages.noctalia-starship-sync = noctaliaStarshipSync;

    apps.nushell = {
      type = "app";
      program = "${self'.packages.nushell}/bin/nu";
      meta.description = "Hermetically wrapped Nushell with Starship and in-store Zoxide";
    };
  };
}