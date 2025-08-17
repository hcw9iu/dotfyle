{ lib, pkgs, config, ... }:

let
  # 560.x 以上驅動（來自最新版核心套件）
  nvidiaDriverChannel = pkgs.linuxPackages_latest.nvidiaPackages.latest;
in {
  # 使用最新 Linux kernel（與驅動版本相容）
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # 僅載入 NVIDIA 驅動
  services.xserver.videoDrivers = [ "nvidia" ];

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    blacklistedKernelModules = [ "nouveau" ];   # 避免衝突
  };

  environment.variables = {
    GBM_BACKEND               = "nvidia-drm";   # Wayland 必需
    LIBVA_DRIVER_NAME         = "nvidia";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND               = "direct";
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "cudatoolkit"
        "nvidia-persistenced"
        "nvidia-settings"
        "nvidia-x11"
      ];
  };

  hardware = {
    nvidia = {
      open                   = false;
      nvidiaSettings         = true;
      powerManagement.enable = true;
      modesetting.enable     = true;
      package                = nvidiaDriverChannel;
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = nvidiaDriverChannel;
      extraPackages   = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        mesa
        egl-wayland
      ];
    };
  };
}