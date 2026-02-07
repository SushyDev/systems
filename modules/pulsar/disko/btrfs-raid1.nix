{ disko, ... }:
{
	imports = [
		disko.nixosModules.disko
	];

	disko.devices = {
		# Define two NVMe disks, each with a GPT partition table.
		disk = {
			nvme0 = {
				type = "disk";
				device = "/dev/nvme0n1";
				content = {
					type = "gpt";
					partitions = {
						ESP = {
							name = "ESP";
							size = "512M";
							type = "EF00";
							content = {
								type = "filesystem";
								format = "vfat";
								mountpoint = "/boot";
							};
						};
						mdadm = {
							size = "100%";
							content = {
								type = "mdraid";
								name = "raid1";
							};
						};
					};
				};
			};
			nvme1 = {
				type = "disk";
				device = "/dev/nvme1n1";
				content = {
					type = "gpt";
					partitions = {
						ESP_BACKUP = {
							name = "ESP-BACKUP";
							size = "512M";
							type = "EF00";
							content = {
								type = "filesystem";
								format = "vfat";
								# No mountpoint here. This is intentional.
							};
						};
						mdadm = {
							size = "100%";
							content = {
								type = "mdraid";
								name = "raid1";
							};
						};
					};
				};
			};
		};

		# This section defines the RAID array.
		mdadm = {
			raid1 = {
				type = "mdadm";
				level = 1; # RAID 1 for mirroring.
				content = {
					# The RAID array will contain a single BTRFS filesystem.
					type = "btrfs";
					# We don't mount the top-level of the BTRFS volume.
					# Instead, we create and mount subvolumes.
					extraArgs = [ "-f" ]; # Pass '-f' to force creation if needed.

					# Define all the subvolumes you want to create.
					subvolumes = {
						# Subvolume for the root filesystem, mounted at /.
						# The '@' naming is a common convention.
						"/@" = {
							mountpoint = "/";
							# It's good practice to set specific mount options.
							mountOptions = [ "compress=zstd" "noatime" ];
						};

						# Subvolume for /home.
						"/@home" = {
							mountpoint = "/home";
							mountOptions = [ "compress=zstd" "noatime" ];
						};

						# Subvolume for /nix. Separating it is recommended
						# for performance and snapshot management.
						"/@nix" = {
							mountpoint = "/nix";
							mountOptions = [ "compress=zstd" "noatime" ];
						};

						# You can add others here if you like, for example:
						# "/@log" = {
						#   mountpoint = "/var/log";
						#   mountOptions = [ "compress=zstd" "noatime" ];
						# };
						# "/@snapshots" = {
						#   mountpoint = "/.snapshots";
						# };
					};
				};
			};
		};
	};
}
