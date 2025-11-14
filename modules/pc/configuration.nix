{ setup, config, lib, inputs, pkgs, ... }:
{
	imports = [
		./packages.nix
		./programs.nix
		./security.nix
		./services.nix

		./system/default.nix
		../shared/oxidation.nix
		./desktop-manager/kde.nix
		# ./hardening.nix
	];

	nixpkgs.config.allowUnfree = true;
	i18n.defaultLocale = "en_US.UTF-8";
	console.earlySetup = true;
	time.timeZone = "Europe/Amsterdam";
	system.stateVersion = "25.05";

	# environment.shellAliases = ''
	# 	alias pbcopy='xclip -selection clipboard'
	# 	alias pbpaste='xclip -selection clipboard -o'
	# '';
	
	nix.settings = {
		substituters = ["https://nix-gaming.cachix.org"];
		trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
	};
}
