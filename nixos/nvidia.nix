{ lib, pkgs, ... }:

{
  nixpkgs.config = {
    allowUnfree          = true;
    nvidia.acceptLicense = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  hardware = {
    nvidia = {
      open               = true;          # 使用 Open Kernel Module
      modesetting.enable = true;
      nvidiaSettings     = false;         # 省去 GTK UI
      package            = pkgs.nvidia;  # ← overlay 提供的 attrset
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = pkgs.nvidia-open;
      extraPackages   = with pkgs; [ egl-wayland ];
    };
  };
}