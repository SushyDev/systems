{ pkgs, ... }:
{
	boot = {
		loader = {
			timeout = null;

			systemd-boot = {
				enable = true;
				consoleMode = "max";
				configurationLimit = 5;
				windows = {
					"tiny-11-pro" = {
						title = "Tiny 11 Pro";
						efiDeviceHandle = "FS0";
					};
				};
			};

			efi = {
				canTouchEfiVariables = true;
				efiSysMountPoint = "/boot";
			};
		};

		tmp.cleanOnBoot = true;

		kernel.sysctl."net.ipv4.ip_unprivileged_port_start" = 80;

		kernelParams = [
			"pci=acpi"
			"quiet"
			"splash"
			"udev.log_level=3"
			"systemd.show_status=auto"
			"rd.udev.log_level=3"
		];
		blacklistedKernelModules = [ "nouveau" ];
		# kernelPackages = pkgs.linuxPackages_latest;
		kernelPackages = pkgs.linuxPackages_cachyos;
	};

	hardware = {
		bluetooth.enable = true;

		nvidia = {
			open = true;
			modesetting.enable = true;
		};
		graphics.enable = true;
	};

	services.xserver.videoDrivers = [ "nvidia" ];
}
