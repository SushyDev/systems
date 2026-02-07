{ pkgs, ... }:

{
	# --- Boot Loader [systemd-boot for Redundant EFI] ---
	boot.loader.systemd-boot.enable = true;
	boot.loader.efi.efiSysMountPoint = "/boot";
	boot.loader.efi.canTouchEfiVariables = true;

	# --- ESP Synchronization Service ---
	# This service runs after every nixos-rebuild to sync the primary ESP
	# to the backup ESP, ensuring the backup is always bootable.
	systemd.services.sync-backup-esp = {
		description = "Sync EFI files to backup ESP";
		
		wantedBy = [ "multi-user.target" ];
		
		# Run after the primary /boot partition is populated by NixOS.
		after = [ "boot-builder.service" ];

		serviceConfig.Type = "oneshot";

		# Provide all necessary binaries (rsync, mount, etc.) in the script's PATH.
		path = with pkgs; [ coreutils util-linux rsync ];

		script = ''
			#!${pkgs.bash}/bin/bash
			set -euo pipefail

			BACKUP_ESP_DEVICE="/dev/disk/by-partlabel/ESP-BACKUP"
			MOUNT_POINT="/mnt/esp-backup"

			if [ -e "$BACKUP_ESP_DEVICE" ]; then
				echo "Backup ESP found. Syncing boot files..."
				mkdir -p "$MOUNT_POINT"
				
				# Mount, sync (mirroring deletes), and unmount the backup ESP.
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

	# --- Automated UEFI Boot Entry Creation for Backup ---
	# This service runs ONCE on the first boot to create a persistent UEFI boot
	# entry for the backup ESP in your motherboard's firmware.
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
					
					# Reliably get disk and partition number for efibootmgr
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
