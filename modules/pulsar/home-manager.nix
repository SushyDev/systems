{ inputs, setup, pkgs, ... }:
{
	home-manager.users.sushy = {
		home.stateVersion = "25.05";

		home.packages = with pkgs; [
			# Add user-specific packages here
		];

		programs.bash.enable = true;
	};
}
