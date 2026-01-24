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

		kernelPackages = pkgs.linuxPackages_latest;
		# kernelPackages = pkgs.linuxPackages_cachyos;
	};

	hardware = {
		i2c.enable = true;

		bluetooth = {
			enable = true;
			settings = {
				General.Experimental = true;
			};

		};

		nvidia = {
			open = true;
			modesetting.enable = true;

			# THIS is the specific fix for the sleep/wake issue.
			# It enables the nvidia-suspend/resume/hibernate systemd services
			# and sets NVreg_PreserveVideoMemoryAllocations=1 automatically.
			powerManagement.enable = true;

			# Keep this false unless you are on a laptop with a very new GPU (Turing+)
			# and specifically want the GPU to turn off completely when not in use.
			# For sleep stability, false is often safer.
			powerManagement.finegrained = false;
		};

		graphics.enable = true;
	};

	services.xserver.videoDrivers = [ "nvidia" ];
}
