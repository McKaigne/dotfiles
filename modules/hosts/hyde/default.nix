{ inputs, config, ... }:
let
  m = config.flake.modules;
in
{
  flake.nixosConfigurations.hyde = inputs.nixpkgs.lib.nixosSystem {
    modules = [
      m.nixos.host-workstation
      m.nixos.hyde-hardware
      m.nixos.blender
      m.nixos.obs
      m.nixos.godot
      m.nixos.containers
      m.nixos.openrgb
      {
        workstation = {
          username = "jekyll";
          hostname = "hyde";
          stateVersion = "25.05";
          system = "x86_64-linux";
          isDesktopCompute = true;
          display = {
            output = "DP-1";
            mode = "1920x1080@240.000";
            scale = "1.0";
            xftDpi = "96";
          };
        };

        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelModules = [ ];
        boot.kernelParams = [
          "nvme_core.default_ps_max_latency_us=0"
          "pcie_aspm=off"
          "systemd.default_device_timeout_sec=30"
        ];

        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        hardware.amdgpu.opencl.enable = true;
        hardware.i2c.enable = true;
      }
    ];
  };
}
