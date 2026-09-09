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
  flake.nixosModules.castorConfiguration = nixosModule;

  perSystem = { pkgs, ... }:
    let
      yaziToml = pkgs.writeText "yazi.toml" ''
        [opener]
        edit = [
          { run = 'hx "$@"', block = true, desc = "Helix" }
        ]

        [open]
        rules = [
          { mime = "text/*", use = [ "edit", "reveal" ] },
          { mime = "application/{json,javascript,x-javascript,xml}", use = [ "edit", "reveal" ] },
          { mime = "application/x-{bat,shellscript,python-code}", use = [ "edit", "reveal" ] },
        ]
      '';

      yaziConfigDir = pkgs.runCommand "yazi-config-dir" {} ''
        mkdir -p $out
        cp ${yaziToml} $out/yazi.toml
      '';

      wrappedYazi = pkgs.symlinkJoin {
        name = "yazi";
        paths = [ pkgs.yazi ];
        buildInputs = [ pkgs.makeWrapper ];
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