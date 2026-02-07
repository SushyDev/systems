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
							size = "1G";
							type = "EF00";
							content = {
								type = "filesystem";
								format = "vfat";
								mountpoint = "/boot";
							};
						};
						root = {
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
							size = "1G";
							type = "EF00";
							content = {
								type = "filesystem";
								format = "vfat";
								# No mountpoint here. This is intentional.
							};
						};
						root = {
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

		# Define the RAID 1 array using mdadm.
		mdadm = {
			raid1 = {
				type = "mdadm";
				level = 1;
				content = {
					type = "filesystem";
					format = "ext4";
					mountpoint = "/";
				};
			};
		};
	};
}
