{ setup, pkgs, ... }:
{
	users.defaultUserShell = pkgs.zsh;

	users.groups."${setup.nixGroupName}" = {
		gid = setup.nixGroupId;
		members = setup.nixGroupMembers;
	};

	users.users."${setup.primaryUser}" = {
		isNormalUser = true;
		extraGroups = [ "wheel" "docker" "i2c" ];
		uid = 1000;
		openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
		];
	};

	users.users.root = {
		openssh.authorizedKeys.keys = [
			"ssh-ed2551 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
		];
	};
}
