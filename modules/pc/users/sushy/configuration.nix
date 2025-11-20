{ inputs, setup, lib, pkgs, ... }:
{
	imports = [
		inputs.dotfiles.homeManagerModules.default
		# inputs.plasma-manager.homeModules.plasma-manager
	];

	dotfiles = {
		enable = true;
		systemFlakePath = setup.systemFlakePath;
	};

	# plasma = {
	# 	enable = true;
	# 	workspace.theme = "breeze-dark"; # Or another theme name like "breeze-light"
	#
	# 	lookAndFeel.name = "org.kde.breezedark.desktop";
	# 	colorScheme.name = "BreezeDark";
	# 	iconTheme.name = "breeze-dark";
	# 	cursorTheme.name = "breeze_cursors";
	# };

	programs.zsh = {
		profileExtra = lib.mkBefore ''
			if [ -z "$KDE_FULL_SESSION" ] && [ "$XDG_SESSION_TYPE" = "tty" ]; then
				exec startplasma-wayland
			fi
		'';
	};

	programs.git = {
		settings.user.name = "SushyDev";
		settings.user.email = "mail@sushy.dev";
		signing.key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIImyhNk+raDf5TXHFWOyWIKw8IQapkhwJ5e+iLQydSFR";
	};

	programs.direnv = {
		enable = true;
		nix-direnv.enable = true;
	};

	home.packages = [];

	# The state version is required and should stay at the version you
	# originally installed
	home.stateVersion = "25.05";
}
