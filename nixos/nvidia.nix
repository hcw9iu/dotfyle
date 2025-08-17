{ lib, pkgs, config, inputs, ... }:

let
  # 只用來拿最新版 NVIDIA 套件的 nixpkgs
  unstablePkgs = import inputs."nvidia-src" { system = pkgs.system; };

  # 560 系列 open-kernel 版驅動（OKM）
  upstreamDrv = unstablePkgs.linuxPackages_6_12.nvidiaPackages_560.open;

in {
  # ---------------------------------------------------------
  # 基本 X11 / Wayland 驅動設定
  # ---------------------------------------------------------
  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
    "nvidia-drm.modeset=1"
    "nvidia_drm.fbdev=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  environment.variables = {
    LIBVA_DRIVER_NAME         = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND               = "direct";
    # GBM_BACKEND = "nvidia-drm";  # 若 Wayland 程式仍當掉再打開
  };

  # ---------------------------------------------------------
  # 允許安裝 unfree 套件並接受 NVIDIA 授權
  # ---------------------------------------------------------
  nixpkgs.config = {
    allowUnfree        = true;
    nvidia.acceptLicense = true;
  };

  # ---------------------------------------------------------
  # NVIDIA 與 OpenGL 套件
  # ---------------------------------------------------------
  hardware = {
    nvidia = {
      open               = true;          # 使用 Open Kernel Modules
      modesetting.enable = true;
      powerManagement.enable = true;
      nvidiaSettings     = false;         # 省去 GTK3 編譯
      package            = upstreamDrv;   # ← 關鍵：直接用 560 open 版 attrset
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = upstreamDrv;
      extraPackages   = with pkgs; [
        egl-wayland
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        mesa
      ];
    };
  };
}