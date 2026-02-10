{
	setup,
	...
}:
{
	security.sudo.wheelNeedsPassword = false;

	# Enable RTKit for PipeWire real-time audio priority
	security.rtkit.enable = true;

	programs._1password.enable = true;
	programs._1password-gui = {
		enable = true;
		# Certain features, including CLI integration and system authentication support,
		# require enabling PolKit integration on some desktop environments (e.g. Plasma).
		polkitPolicyOwners = setup.managedUsers;
	};

	environment.etc = {
		"1password/custom_allowed_browsers" = {
			text = ''
				vivaldi-bin
			'';
			mode = "0755";
		};
	};

	programs.fuse.userAllowOther = true;
}
