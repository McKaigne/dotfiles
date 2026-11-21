{ inputs, config, ... }:
{
  flake.modules.nixos.helium = {
    home-manager.sharedModules = [ config.flake.modules.homeManager.helium ];
    nixpkgs.overlays = [
      (final: _: {
        helium-widevine =
          inputs.helium.packages.${final.stdenv.hostPlatform.system}.helium-widevine;
        helium = final.helium-widevine.overrideAttrs (oldAttrs: {
          postFixup = (oldAttrs.postFixup or "") + ''
            wrapProgram "$out/bin/helium" \
              --add-flags "--enable-features=HeliumMiddleClickAutoscroll" \
              --add-flags "--force-device-scale-factor=1.0"
          '';
        });
      })
    ];
  };
}
