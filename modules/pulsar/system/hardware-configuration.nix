# Hardware configuration for pulsar server
{ lib, pkgs, ... }:
{
	boot.initrd.availableKernelModules = [ "vmd" "xhci_pci" "ahci" "nvme" "usbhid" ];
	boot.initrd.kernelModules = [ ];
	boot.kernelModules = [ "kvm-intel" ];
	boot.extraModulePackages = [ ];

	# Boot Loader - systemd-boot for redundant EFI
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.efiSysMountPoint = "/boot";
	boot.loader.efi.canTouchEfiVariables = true;

	nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
	hardware.cpu.intel.updateMicrocode = lib.mkDefault true;

	# ESP Synchronization Service
	systemd.services.sync-backup-esp = {
		description = "Sync EFI files to backup ESP";
		
		wantedBy = [ "multi-user.target" ];
		
		after = [ "boot-builder.service" ];

		serviceConfig.Type = "oneshot";

		path = with pkgs; [ coreutils util-linux rsync ];

		script = ''
			#!${pkgs.bash}/bin/bash
			set -euo pipefail

			BACKUP_ESP_DEVICE="/dev/disk/by-partlabel/ESP-BACKUP"
			MOUNT_POINT="/mnt/esp-backup"

			if [ -e "$BACKUP_ESP_DEVICE" ]; then
				echo "Backup ESP found. Syncing boot files..."
				mkdir -p "$MOUNT_POINT"
				
				mount "$BACKUP_ESP_DEVICE" "$MOUNT_POINT"
				rsync -a --delete /boot/ "$MOUNT_POINT/"
				umount "$MOUNT_POINT"
				rmdir "$MOUNT_POINT"
				
				echo "Backup ESP sync complete."
			else
				echo "WARNING: Backup ESP partition 'ESP-BACKUP' not found. Skipping sync." >&2
			fi
		'';
	};

	# Automated UEFI Boot Entry Creation for Backup
	systemd.services.setup-backup-boot-entry = {
		description = "Create UEFI boot entry for backup ESP";
		wantedBy = [ "multi-user.target" ];

		serviceConfig = {
			Type = "oneshot";
			RemainAfterExit = true;
		};

		requires = [ "sys-firmware-efi-efivars.mount" ];
		after = [ "sys-firmware-efi-efivars.mount" ];

		path = with pkgs; [ coreutils efibootmgr gnugrep util-linux ];

		script = ''
			#!${pkgs.bash}/bin/bash
			set -euo pipefail

			if ! efibootmgr | grep -q "NixOS (Backup)"; then
				BACKUP_ESP_SYMLINK="/dev/disk/by-partlabel/ESP-BACKUP"

				if [ -L "$BACKUP_ESP_SYMLINK" ]; then
					REAL_DEVICE_PATH=$(readlink -f "$BACKUP_ESP_SYMLINK")
					
					DISK_DEVICE="/dev/$(lsblk -no pkname "$REAL_DEVICE_PATH")"
					PARTITION_NUMBER=$(lsblk -no PARTN "$REAL_DEVICE_PATH")
					
					echo "Creating UEFI boot entry for backup ESP..."
					
					efibootmgr -c -d "$DISK_DEVICE" -p "$PARTITION_NUMBER" \
						-L "NixOS (Backup)" -l '\EFI\systemd\systemd-bootx64.efi'
				else
					echo "WARNING: Backup ESP device not found, cannot create UEFI boot entry." >&2
				fi
			else
				echo "NixOS (Backup) UEFI entry already exists, skipping creation."
			fi
		'';
	};
}
