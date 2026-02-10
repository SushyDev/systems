{ pkgs, ... }:
{
	services.openssh = {
		enable = true;
		ports = [ 22 ];
		extraConfig = "UsePrivilegeSeparation sandbox";
	};

	virtualisation.docker = {
		enable = true;
		enableOnBoot = true;
		rootless = {
			enable = true;
			setSocketVariable = true;
		};
	};

	# System optimizations

	# Enable zram for better memory management
	zramSwap.enable = true;
	zramSwap.algorithm = "zstd";

	# Enable earlyoom for better memory management
	services.earlyoom.enable = true;

	# Enable fstrim for SSD optimization
	services.fstrim.enable = true;

	# Disable unnecessary services
	services.tlp.enable = false;
	services.printing.enable = false;
	services.blueman.enable = false;
	systemd.services.systemd-udev-settle.enable = false;
	systemd.services.NetworkManager-wait-online.enable = false;
}
