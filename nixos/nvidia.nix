{ lib, pkgs, config, ... }:

let
  nvidiaDrv = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version             = "565.77";
    useOpenKernelModule = true;   # 必開：RTX 50 系列只認 OKM

    # 64-bit 主驅動檔 .run
    sha256_64bit         = "sha256-3o0z0ZYmEWlNgH6b6w7TjV7n6tp/hmX3Dgwrqen+o5Y=";
    # 32-bit、settings 皆省略
    sha256_32bit         = null;
    settingsSha256       = null;

    # nvidia-persistenced
    persistencedSha256   = "sha256-gdkxArLh8NRldMEy7RGrGdqst0b9+V1HBqI8M7JMOfw=";
  };
in
{
  # 允許 unfree 套件並接受 NVIDIA 授權
  nixpkgs.config = {
    allowUnfree        = true;
    nvidia.acceptLicense = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
  ];

  hardware = {
    nvidia = {
      open               = true;     # Open Kernel Module
      modesetting.enable = true;
      nvidiaSettings     = false;    # 不編 GTK UI
      package            = nvidiaDrv;
    };

    opengl = {
      enable          = true;
      driSupport32Bit = true;
      package         = nvidiaDrv;
      extraPackages   = with pkgs; [ egl-wayland ];
    };
  };
}