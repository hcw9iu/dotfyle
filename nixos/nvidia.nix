{ lib, pkgs, config, ... }:
let
  nvidiaDriverChannel =
    #config.boot.kernelPackages.nvidiaPackages.stable; # stable, latest, beta, production, etc.
    config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "565.57.01";
      #sha256_64bit  = "0yic33xx1b3jbgciphlwh6zqfj21vx9439zm0j45wf2yb17fksvf";
      #settingsSha256 = "1v8z8c895gvvr2y3974iahjpll8wjimv6w4g4qc9h460qhwc3k2b";
      #persistencedSha256 = "1qpsrmxz3y741qh4x91qbrkkc0x8hnifp7pfrsxmwnwf796r2904";
      sha256_64bit       = "0000000000000000000000000000000000000000000000000000";
      settingsSha256     = "0000000000000000000000000000000000000000000000000000";
      persistencedSha256 = "0000000000000000000000000000000000000000000000000000";
    };
    #nvidiaDriverChannel = pkgs.linuxPackages_latest.nvidiaPackages.latest;
in {
  # Load nvidia driver for Xorg and Wayland
  #boot.kernelPackages = pkgs.linuxPackages_latest;
   
  services.xserver.videoDrivers =
    [ "nvidia" "displayLink" ]; # or "nvidiaLegacy470 etc.
  boot.kernelParams =
    lib.optionals (lib.elem "nvidia" config.services.xserver.videoDrivers) [
      "nvidia-drm.modeset=1"
      "nvidia_drm.fbdev=1"
      "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    ];
  environment.variables = {
    # GBM_BACKEND = "nvidia-drm"; # If crash in firefox, remove this line
    LIBVA_DRIVER_NAME = "nvidia"; # hardware acceleration
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    NVD_BACKEND = "direct";
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
      open = false;
      nvidiaSettings = true;
      powerManagement.enable =
        true; # This can cause sleep/suspend to fail and saves entire VRAM to /tmp/
      modesetting.enable = true;
      package = nvidiaDriverChannel;
    };
    #graphics = {
      #enable = true;
      #package = nvidiaDriverChannel;
      #enable32Bit = true;
      #extraPackages = with pkgs; [
        #nvidia-vaapi-driver
        #vaapiVdpau
        #libvdpau-va-gl
        #mesa
        #egl-wayland
      #];
    #};
    opengl = {
      enable = true;
      driSupport32Bit = true;
      package = nvidiaDriverChannel;
      extraPackages = with pkgs; [
        nvidia-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        mesa
        egl-wayland
      ];
    };
  };
}
