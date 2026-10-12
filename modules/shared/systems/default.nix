{ self, inputs, ... }: {
  systems = [ "x86_64-linux" ];

  perSystem = { pkgs, system, ... }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

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
          fd -t f -e nix -X nixfmt --check
        else
          fd -t f -e nix -X nixfmt
        fi
      '';
    };

    checks = {
      castor-eval = pkgs.runCommand "check-castor-eval" { } ''
        echo "${self.nixosConfigurations.castor.config.system.build.toplevel.drvPath}" > $out
      '';

      hyde-eval = pkgs.runCommand "check-hyde-eval" { } ''
        echo "${self.nixosConfigurations.hyde.config.system.build.toplevel.drvPath}" > $out
      '';

      myNiri = self.packages.${system}.myNiri;
    };
  };
}
