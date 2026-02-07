{ setup, ... }:
{
	imports = [ 
		./users-and-groups.nix
		./hardware-configuration.nix
	];

	system.activationScripts.setupSystemFlake = {
		text = ''
			mkdir -p ${setup.systemFlakePath}
			chown -R root:nix ${setup.systemFlakePath}
			chmod -R g+rwX ${setup.systemFlakePath}
			
			# Configure git to trust the flake directory
			git config --global --add safe.directory ${setup.systemFlakePath}
		'';
	};
}
