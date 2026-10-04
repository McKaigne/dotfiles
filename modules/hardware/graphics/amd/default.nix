{ pkgs, ... }: {
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd # Enables AMD HIP compute for Blender Cycles rendering
    ];
  };

  # Early KMS for amdgpu to avoid Wayland session race conditions
  boot.initrd.kernelModules = [ "amdgpu" ];
}
