{ ... }:
{
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.channel.enable = true;

	nixpkgs.config.allowUnfree = true;
}
