{ pkgs, ... }:
{
	# --- Programs
	environment.systemPackages = [
		pkgs.vim
		pkgs.jq
		pkgs.gitMinimal

		# I can just nix-shell -p these
		#pkgs.dnsutils
		#pkgs.btop
	];
}
