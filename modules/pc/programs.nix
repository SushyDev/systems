{ pkgs, ... }:
{
	programs.nano.enable = false;
	programs.nix-index.enable = true;
	programs.zsh.enable = true;

	programs.steam = {
		enable = true; # Master switch, already covered in installation
		remotePlay.openFirewall = true;  # For Steam Remote Play
		dedicatedServer.openFirewall = true; # For Source Dedicated Server hosting
		extraCompatPackages = [
			pkgs.proton-ge-bin
		];
	};

	programs.gamemode.enable = true;
}
