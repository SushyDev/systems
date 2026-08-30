{ config, pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  # pc configures no display manager (the plan there was to exec
  # startplasma-wayland from a tty). A tablet has no keyboard attached by
  # default, so it gets a real greeter. Wayland, since Plasma 6's X11
  # session has no working touch rotation.
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;

    # The on-screen keyboard button in the greeter is inert without both
    # of these. SDDM runs as its own user with its own Qt plugin path, so
    # having qtvirtualkeyboard in environment.systemPackages does not
    # reach it -- it has to be in extraPackages -- and the greeter only
    # offers an input method it has been told to load.
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

    # Touch-first additions that pc has no use for. maliit-keyboard is
    # top-level, not under kdePackages.
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

  # pc excludes calligra by omission and then installs it; on a tablet it
  # is 1.5G of office suite nobody asked for, so it stays out entirely.
}
