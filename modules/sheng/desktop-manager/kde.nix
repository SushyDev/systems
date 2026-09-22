{ config, pkgs, ... }:
{
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

  environment.systemPackages = [
    # maliit-keyboard is top-level, not under kdePackages.
    pkgs.maliit-keyboard
    pkgs.kdePackages.qtvirtualkeyboard
  ];
}
