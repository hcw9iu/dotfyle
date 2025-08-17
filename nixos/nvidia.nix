{ pkgs, config, ... }:

let
  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.beta;  # 565 或 550 皆可
in {
  # 同時載入 amdgpu+nvidia 模組，PRIME 會自動切 GPU
  services.xserver.videoDrivers = [ "nvidia" "amdgpu" ];

  boot = {
    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  environment.variables = {
    GBM_BACKEND               = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME         = "nvidia";
    WLR_NO_HARDWARE_CURSORS   = "1";   # 如無游標問題可移除
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

      prime = {
        offload.enable         = true;
        offload.enableOffloadCmd = true;
        sync.enable            = false;
        # 若確定 BusId 固定，再設定，否則可省略交由 kernel 自判
        # amdgpuBusId = "PCI:5:0:0";
        # nvidiaBusId = "PCI:1:0:0";
      };
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = nvidiaDriver;
      extraPackages   = with pkgs; [
        egl-wayland
        nvidia-vaapi-driver
      ];
    };
  };

  nix.settings = {
    substituters = [ "https://cuda-maintainers.cachix.org" ];
    trusted-public-keys = [
      "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];
  };

  environment.systemPackages = with pkgs; [
    vulkan-tools
    glxinfo
    libva-utils
  ];
}