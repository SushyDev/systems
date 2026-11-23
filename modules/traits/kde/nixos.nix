{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  services.dbus.enable = true;
  services.udisks2.enable = true;
  services.upower.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  environment.systemPackages = [
    pkgs.kdePackages.plasma-pa
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
