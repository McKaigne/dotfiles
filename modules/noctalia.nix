
{ self, inputs, ... }:
let
  nixosModule = { config, pkgs, ... }: {
    environment.systemPackages = [
      self.packages.${pkgs.stdenv.hostPlatform.system}.noctalia
    ];

    systemd.tmpfiles.rules = [
      "d /home/${config.mainUser}/.config/noctalia 0755 ${config.mainUser} users -"
      "C+ /home/${config.mainUser}/.config/noctalia/config.toml 0644 ${config.mainUser} users - ${./noctalia.toml}"
    ];
  };
in
{
  flake.nixosModules.noctalia = nixosModule;

  perSystem = { pkgs, ... }:
    let
      rawNoctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    in
    {
      packages.noctalia = rawNoctalia;

      apps.noctalia = {
        type = "app";
        program = "${rawNoctalia}/bin/noctalia";
        meta.description = "Noctalia v5 native C++ Wayland desktop shell";
      };
    };
}
