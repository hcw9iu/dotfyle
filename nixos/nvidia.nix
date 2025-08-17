{ lib, pkgs, ... }:

{
  # 1. 允許 unfree 並接受 NVIDIA 授權
  nixpkgs.config = {
    allowUnfree        = true;
    nvidia.acceptLicense = true;
  };

  # 2. X11/Wayland 載入 NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  # 3. 核心參數
  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  # 4. 驅動與 OpenGL
  hardware = {
    nvidia = {
      open               = true;                # 啟用 OKM
      modesetting.enable = true;
      nvidiaSettings     = false;               # 不編 GTK UI
      package            = pkgs.nvidia-open-560;# 560.42.04 OKM attrset
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = pkgs.nvidia-open-560;
      extraPackages   = with pkgs; [ egl-wayland ];
    };
  };

  # 5. 可選環境變數（若遇到 Wayland 相容性問題再打開）
  # environment.variables.GBM_BACKEND = "nvidia-drm";
}