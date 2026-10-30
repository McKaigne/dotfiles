{ self, inputs, ... }: {
  flake.nixosConfigurations.hyde = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.hydeHardware
      self.nixosModules.baseWorkstation

      # Heavy Studio, Compute & Production Suite (Desktop Only)
      self.nixosModules.blender
      self.nixosModules.kdenlive
      self.nixosModules.obs
      self.nixosModules.godot
      self.nixosModules.containers

      (_: {
        networking.hostName = "hyde";
        mainUser = "jekyll";
        environment.sessionVariables.XFT_DPI = "96";
        time.timeZone = "Asia/Manila";

        workstation.display = {
          output = "DP-1";
          mode = "1920x1080@240.000";
          scale = "1.0";
        };

        # Kingston NV2 APST fix + AMD KMS
        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelModules = [ ];
        boot.kernelParams = [
          "nvme_core.default_ps_max_latency_us=0"
          "pcie_aspm=off"
          "systemd.default_device_timeout_sec=30"
        ];

        # Declarative AMD OpenCL, Graphics Runtime & Hardware I2C for DDC/CI
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        hardware.amdgpu.opencl.enable = true;
        hardware.i2c.enable = true;

        system.stateVersion = "25.05";
      })
    ];
  };
}
