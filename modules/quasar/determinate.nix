{ self, nixpkgs, determinateNix, setup, ... }:
{
	nix.enable = false;

	determinateNix.customSettings = {
		experimental-features = "nix-command flakes external-builders";
		trusted-users = setup.managedUsersAndRoot;
		lazy-trees = true;
		# external-builders = builtins.toJSON [
		# 	{
		# 		systems = [ "x86_64-linux" "aarch64-linux" ];
		# 		program = "/usr/local/bin/darwin-nixd";
		# 		args = [ "builder" ];
		# 	}
		# ];
	};
}
