{ config, inputs, setup, pkgs, ... }:
{
	home-manager.useGlobalPkgs = true;
	home-manager.useUserPackages = true;
	home-manager.extraSpecialArgs = {
		inherit inputs setup;
		systemConfig = config;
	};

	home-manager.users.sushy = import ./users/sushy/configuration.nix;

	# Emacs is managed as a user service via home-manager, not system-wide
	# This avoids startup failures and allows per-user configuration
	services.emacs.enable = true;

	# Ensure home-manager activation runs after nixos-rebuild
	# The Home Manager NixOS module doesn't automatically run activation scripts,
	# so we trigger it manually after nixos-rebuild completes
	system.activationScripts.home-manager-activation = {
		text = ''
			echo "Activating Home Manager for sushy..."
			export PATH="${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.findutils}/bin:$PATH"
			profileDir="$(${pkgs.coreutils}/bin/readlink -m /home/sushy/.local/state/nix/profiles/home-manager)"
			if [[ -x "$profileDir/activate" ]]; then
				${pkgs.coreutils}/bin/su - sushy -c "bash $profileDir/activate --driver-version 1" 2>/dev/null || true
			fi
		'';
		deps = [];
	};
}
