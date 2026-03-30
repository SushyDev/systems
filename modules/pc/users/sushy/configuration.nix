{ 
	config,
	inputs,
	lib,
	pkgs,
	setup,
	systemConfig,
	...
}:
{
	imports = [
		inputs.dotfiles.homeManagerModules.default
		# inputs.plasma-manager.homeModules.plasma-manager
		../../../shared/user/git.nix
		../../../shared/user/ddev.nix
		../../../shared/user/direnv.nix
	];

	dotfiles = {
		enable = true;
		systemFlakePath = setup.systemFlakePath;
	};

	home.packages = [
		pkgs.mpv
	];

	# The state version is required and should stay at the version you
	# originally installed
	home.stateVersion = "25.05";
}
