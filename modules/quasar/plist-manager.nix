{
	programs.nix-plist-manager = {
		enable = true;

		options = {
			applications = {
				systemSettings = {
					general = {
						softwareUpdate = {
							automaticallyDownloadNewUpdatesWhenAvailable = true;
						};
					};
				};
			};
		};
	};
}
