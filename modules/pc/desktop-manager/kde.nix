{ config, pkgs, ... }:
{
	services.desktopManager.plasma6.enable = true;

	services.dbus.enable = true;
	services.udisks2.enable = true;
	services.upower.enable = true;
	services.pipewire = {
		enable = true;
		# alsa.enable = true;
		# alsa.support32Bit = true;
		# jack.enable = true; # Optional, only if you want JACK support
		pulse.enable = true;
	};

	environment.systemPackages = [
		# pkgs.kdePackages.dolphin
		# pkgs.kdePackages.kdialog
		# pkgs.kdePackages.plasma-browser-integration
		pkgs.kdePackages.plasma-pa
		# pkgs.kdePackages.systemsettings
		pkgs.kdePackages.calligra
	];

	environment.plasma6.excludePackages = [
		pkgs.kdePackages.elisa
		# pkgs.kdePackages.kate
		pkgs.kdePackages.oxygen
		pkgs.kdePackages.okular
		pkgs.kdePackages.khelpcenter
		pkgs.kdePackages.kinfocenter
		pkgs.kdePackages.gwenview
	];
}
