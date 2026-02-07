{ setup, ... }:
{
	users.groups.nix = {
		gid = setup.nixGroupId;
	};

	users.groups.media = {
		gid = 1000; # Using a GID that won't conflict
	};

	users.users.sushy = {
		isNormalUser = true;
		extraGroups = [ "wheel" "docker" "media" "nix" ];
	};

	# --- SSH
	# Only sushy can SSH in with key-based authentication
	users.users.sushy.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
	];
}

