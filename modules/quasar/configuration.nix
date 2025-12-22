{
	base,
	inputs,
	pkgs, 
	...
}:
{
	imports = [
		./darwin.nix
		../shared/oxidation.nix
	];

	nixpkgs.overlays = [ inputs.nix-darwin-apps.overlays.default ];
	nixpkgs.config.allowUnfree = true;

	# List packages installed in system profile. To search by name, run:
	# $ nix-env -qaP | grep wget
	environment.systemPackages = [
		# pkgs.opencode
		# pkgs.qemu
		pkgs.openssh
		# pkgs.stow
		pkgs._1password-gui-beta
		pkgs._1password-cli
		pkgs.raycast
		# pkgs.firefox
		pkgs.obsidian
		pkgs.ddev
		pkgs.opencode

		# My own overlay
		# # pkgs.cloudflare-warp-gui
		# # pkgs.google-chrome-canary
		pkgs.dbeaver
		pkgs.ghostty
		pkgs.orbstack
		pkgs.setapp
		pkgs.spotify
		pkgs.vivaldi
	];
}
