{ 
	config,
	inputs,
	lib,
	pkgs,
	setup,
	...
}:
{
	imports = [
		inputs.nix-plist-manager.homeManagerModules.default
		inputs.dotfiles.homeManagerModules.default
		../shared/configuration.nix
		../shared/nix-plist-manager.nix
		../shared/1password.nix
		../shared/direnv.nix
	];

	dotfiles = {
		enable = true;
		systemFlakePath = setup.systemFlakePath;
		git = {
			sshSignPackage = "${lib.getBin pkgs._1password-gui}/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
		};
		ssh = {
			identityAgentPath = "\"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\"";
		};
	};

	home.packages = [ 
		# pkgs.go
		pkgs.utm
		pkgs.discord
		pkgs.blender
		# pkgs.ollama
	];

 	programs.git = {
		settings.user.name = "SushyDev";
		settings.user.email = "mail@sushy.dev";
 		signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImyhNk+raDf5TXHFWOyWIKw8IQapkhwJ5e+iLQydSFR";
 	};
}
