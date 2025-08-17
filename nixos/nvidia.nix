{ lib, pkgs, config, inputs, ... }:

let
  # 提取 unstable 裡的驅動版本與下載網址
  unstableDrv =
    (import inputs."nvidia-src" { system = pkgs.system; })
    .linuxPackages_latest.nvidia_x11;

  nvidiaDriver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version            = unstableDrv.version;        # 例： "560.42.04"
    sha256_64bit       = unstableDrv.src.outputHash; # 直接引用現成雜湊
    settingsSha256     = unstableDrv.settings.src.outputHash;
    persistencedSha256 = unstableDrv.persistenced.src.outputHash;
  };
in {
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    package              = nvidiaDriver;  # ← 用自己 build 的 560
    modesetting.enable   = true;
    nvidiaSettings       = false;         # GTK 失敗就先關掉；之後可裝 pkgs.nvidia-settings
  };
  hardware.opengl = {
    enable          = true;
    driSupport32Bit = true;
    package         = nvidiaDriver;
    extraPackages   = with pkgs; [ egl-wayland ];
  };
}