{ setup, ... }:
{
	imports = [ 
		./nix.nix
		./networking.nix
		./users-and-groups.nix

		./hardware-configuration.nix
	];

	system.activationScripts.setupSystemFlake = {
		text = ''
			mkdir -p ${setup.systemFlakePath}
			chown -R root:nix ${setup.systemFlakePath}
			chmod -R g+rwX ${setup.systemFlakePath}
		'';
	};
}
