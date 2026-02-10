{ inputs, setup, ... }:
{
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
	home-manager.extraSpecialArgs = {
		inherit inputs setup;
	};

	home-manager.users.sushy = import ./users/sushy/configuration.nix;

	# Emacs is managed as a user service via home-manager, not system-wide
	# This avoids startup failures and allows per-user configuration
	services.emacs.enable = false;
}
