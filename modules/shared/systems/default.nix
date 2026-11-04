{ self, inputs, ... }: {
  systems = [ "x86_64-linux" ];

  perSystem =
    { pkgs, system, ... }:
    let
      statixConf = pkgs.writeText "statix.toml" ''
        disabled = [ "repeated_keys" ]
      '';
    in
    {
      _module.args.pkgs = inputs.nixpkgs.legacyPackages.${system};

      formatter = pkgs.writeShellApplication {
        name = "nixfmt-wrapper";
        runtimeInputs = [
          pkgs.fd
          pkgs.nixfmt
        ];
        text = ''
          export LC_ALL=C.UTF-8
          export LANG=C.UTF-8

          check=0
          for arg in "$@"; do
            if [ "$arg" = "--check" ]; then
              check=1
            fi
          done

          if [ "$check" -eq 1 ]; then
            fd -t f -e nix -X nixfmt -w 80 --check
          else
            fd -t f -e nix -X nixfmt -w 80
          fi
        '';
      };

      checks = {
        castor-eval =
          let
            drv = builtins.unsafeDiscardStringContext self.nixosConfigurations.castor.config.system.build.toplevel.drvPath;
          in
          pkgs.runCommand "check-castor-eval" { } ''
            echo "${drv}" > $out
          '';

        hyde-eval =
          let
            drv = builtins.unsafeDiscardStringContext self.nixosConfigurations.hyde.config.system.build.toplevel.drvPath;
          in
          pkgs.runCommand "check-hyde-eval" { } ''
            echo "${drv}" > $out
          '';

        niri-validate-hyde =
          let
            niriText =
              self.nixosConfigurations.hyde.config.home-manager.users.jekyll.xdg.configFile."niri/config.kdl".text;
            niriConf = pkgs.writeText "niri-hyde.kdl" niriText;
          in
          pkgs.runCommand "check-niri-validate-hyde"
            {
              nativeBuildInputs = [ pkgs.niri ];
            }
            ''
              export HOME=$(mktemp -d)
              export XDG_RUNTIME_DIR=$(mktemp -d)
              niri validate -c ${niriConf}
              touch $out
            '';

        statix-check =
          pkgs.runCommand "check-statix"
            {
              nativeBuildInputs = [ pkgs.statix ];
            }
            ''
              statix check --config ${statixConf} ${self}/modules
              touch $out
            '';

        deadnix-check =
          pkgs.runCommand "check-deadnix"
            {
              nativeBuildInputs = [ pkgs.deadnix ];
            }
            ''
              deadnix -f ${self}/modules
              touch $out
            '';
      };
    };
}
