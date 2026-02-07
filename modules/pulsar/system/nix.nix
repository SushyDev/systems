{ pkgs, ... }:
{
	nix = {
		settings = {
			experimental-features = [ "nix-command" "flakes" ];
			auto-optimise-store = true;
			cores = 0; # Use all cores
			max-jobs = "auto";
			substituters = [
				"https://cache.nixos.org"
				"https://nix-community.cachix.org"
			];
			trusted-public-keys = [
				"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
				"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
			];
			download-buffer-size = 2147483648;
		};
		gc = {
			automatic = true;
			dates = "daily";
			options = "--delete-older-than 3d";
		};
	};

	programs.nix-ld.enable = true;
}

