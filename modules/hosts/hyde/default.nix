{
  inputs,
  config,
  ...
}: let
  m = config.flake.modules;
  mkHost = import ../_mkHost.nix {inherit inputs m;};
in {
  flake.nixosConfigurations.hyde = mkHost "hyde" {
    username = "jekyll";
    hostname = "hyde";
    stateVersion = "25.05";
    system = "x86_64-linux";

    desktop = "umbriel";
    screenWidth = 1920;

    git = {
      name = "McKaigne";
      email = "abellorchristian2007@gmail.com";
    };
  };

  flake.modules.nixos.host-hyde = {pkgs, ...}: {
    imports = with m.nixos; [
      hyde-hardware
      blender
      obs
      godot
      containers
      openrgb
    ];

    boot.initrd.kernelModules = ["amdgpu"];
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
    services.xserver.videoDrivers = ["amdgpu"];

    # DDC/CI monitor brightness.
    hardware.i2c.enable = true;
    environment.systemPackages = [pkgs.ddcutil];

    environment.sessionVariables.XFT_DPI = "96";

    services.displayManager.noctalia-greeter.settings.output.name = "DP-1";

    # nsync: deploy Noctalia GUI tweaks from this machine.
    home-manager.sharedModules = [m.homeManager.noctalia-gui-sync];
  };
}
