{
  pkgs,
  ...
}: {
  services.displayManager.sddm = {
    enable         = true;          # 開啟 SDDM
    wayland.enable = true;          # 同時支援 Wayland
    theme          = "sddm-sugar-dark";
  };

  environment.systemPackages = with pkgs; [
    sddm-sugar-dark             # 安裝主題檔
  ];
}