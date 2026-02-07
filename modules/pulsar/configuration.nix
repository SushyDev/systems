{ setup, config, lib, inputs, pkgs, ... }:
{
	imports = [
		./bootloader.nix
		./packages.nix
		./programs.nix
		./security.nix
		./services.nix

		./system/default.nix
		../shared/oxidation.nix
	];

	# --- System
	system.stateVersion = "25.05";

	# --- Swap
	#swapDevices = lib.mkForce [];

	# --- Networking
	networking.hostName = "pulsar";

	# --- Nix Config
	nix.settings.experimental-features = [ "nix-command" "flakes" ];
	nix.channel.enable = true;
	#nix.nixPath = ["nixpkgs=${nixpkgs.url}"];

	nixpkgs.config.allowUnfree = true;

	# --- Shared mount
	# systemd.mounts = [
	#   {
	#     # Bind mount the project directory onto itself to apply rshared
	#     # This is safer than applying it to the whole root filesystem.
	#     where = "/";
	#     what = "none"; # Source and destination are the same
	#     type = "none";
	#     options = "bind,rshared";
	#   }
	# ];
}
