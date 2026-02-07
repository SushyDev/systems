{ ... }:
{
	users.groups.media = {
		gid = 1000;
	};

	users.users.sushy = {
		isNormalUser = true;
		extraGroups = [ "wheel" "docker" "media" ];
	};

	# SSH key management
	users.users.sushy.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
	];

	users.users.root.openssh.authorizedKeys.keys = [
		"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
	];
}
