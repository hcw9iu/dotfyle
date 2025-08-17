{ pkgs, config, ... }:

let
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.beta;
in {
  # 只載入 nvidia driver
  services.xserver.videoDrivers = [ "nvidia" ];

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    # 若想徹底不讓 iGPU 驅動載入，可一起封鎖
    blacklistedKernelModules = [ "nouveau" "amdgpu" "radeon" ];
  };

  environment.variables = {
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME         = "nvidia";
    NIXOS_OZONE_WL            = "1";
    MOZ_ENABLE_WAYLAND        = "1";
  };

  nixpkgs.config = {
    nvidia.acceptLicense = true;
    allowUnfree = true;
  };

  hardware = {
    nvidia = {
      open                 = false;
      nvidiaSettings        = true;
      powerManagement.enable = true;
      modesetting.enable     = true;
      package                = nvidiaDriver;
      # 移除 prime 區段 → 完全不啟用 iGPU
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = nvidiaDriver;
      extraPackages   = with pkgs; [ egl-wayland ];
    };
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    glxinfo
  ];
}