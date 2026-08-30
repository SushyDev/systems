{ config, pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  # Enabling SDDM is what switches nixos-sheng's greeter fixes on. Wayland,
  # since Plasma 6's X11 session has no working touch rotation.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # Both are needed: SDDM has its own Qt plugin path, so systemPackages
    # does not reach it, and the greeter only loads an input method it is told
    # to.
    extraPackages = [ pkgs.kdePackages.qtvirtualkeyboard ];
    settings.General.InputMethod = "qtvirtualkeyboard";
  };

  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = [
    pkgs.kdePackages.plasma-pa

    # maliit-keyboard is top-level, not under kdePackages.
    pkgs.maliit-keyboard
    pkgs.kdePackages.qtvirtualkeyboard
  ];

  environment.plasma6.excludePackages = [
    pkgs.kdePackages.elisa
    pkgs.kdePackages.oxygen
    pkgs.kdePackages.okular
    pkgs.kdePackages.khelpcenter
    pkgs.kdePackages.kinfocenter
    pkgs.kdePackages.gwenview
  ];

}
