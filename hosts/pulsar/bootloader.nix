{
  config,
  lib,
  pkgs,
  ...
}:
{
  # --- Boot Loader [systemd-boot for Redundant EFI] ---
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;

  # --- ESP Synchronization ---
  # Mirror the primary ESP onto the backup ESP every time the bootloader is installed.
  boot.loader.systemd-boot.extraInstallCommands =
    let
      backupDevice = "/dev/disk/by-partlabel/ESP-BACKUP";
      mountPoint = "/mnt/esp-backup";
      coreutil = lib.getExe' pkgs.coreutils;
      utility = lib.getExe' pkgs.util-linux;
    in
    ''
      if [ -e ${backupDevice} ]; then
        ${coreutil "mkdir"} -p ${mountPoint}
        ${utility "mount"} ${backupDevice} ${mountPoint}
        ${lib.getExe pkgs.rsync} -a --delete ${config.boot.loader.efi.efiSysMountPoint}/ ${mountPoint}/
        ${utility "umount"} ${mountPoint}
        ${coreutil "rmdir"} ${mountPoint}
      else
        echo "WARNING: Backup ESP partition 'ESP-BACKUP' not found. Skipping sync." >&2
      fi
    '';

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

    path = with pkgs; [
      coreutils
      efibootmgr
      gnugrep
      util-linux
    ];

    script = ''
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
