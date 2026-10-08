{ self, inputs, ... }: {
  flake.nixosConfigurations.hyde = inputs.nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    specialArgs = { inherit inputs self; };
    modules = [
      inputs.home-manager.nixosModules.home-manager
      self.nixosModules.hydeHardware
      self.nixosModules.baseWorkstation
      ({ pkgs, ... }: {
        networking.hostName = "hyde";
        mainUser = "jekyll";
        time.timeZone = "Asia/Manila";

        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        hardware.enableAllHardware = true;

        # Kingston NV2 APST fix + AMD KMS
        boot.initrd.kernelModules = [ "amdgpu" ];
        boot.kernelParams = [
          "nvme_core.default_ps_max_latency_us=0"
          "pcie_aspm=off"
          "systemd.default_device_timeout_sec=infinity"
        ];

        boot.tmp.useTmpfs = true;
        boot.tmp.tmpfsSize = "50%";

        zramSwap = {
          enable = true;
          algorithm = "zstd";
          memoryPercent = 50;
        };

        boot.kernel.sysctl = {
          "vm.swappiness" = 10;
        };

        networking.networkmanager.enable = true;
        services.openssh.enable = true;

        # AMD Graphics & HIP ROCm Compute for Blender Cycles
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
          extraPackages = with pkgs; [
            rocmPackages.clr.icd
          ];
        };

        system.stateVersion = "25.05";
      })
    ];
  };
}
