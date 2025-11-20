{ nixpkgs, pkgs, ... }:
{
	# nixpkgs.overlays = [
	# 	(final: prev: {
	# 		php83-optimized = prev.php83.overrideAttrs (oldAttrs: {
	# 			configureFlags = oldAttrs.configureFlags ++ [
	# 				"--enable-opcache"
	# 				"--with-pic"
	# 			];
	#
	# 			NIX_CFLAGS_COMPILE = (oldAttrs.NIX_CFLAGS_COMPILE or "") + " " + builtins.concatStringsSep " " [
	# 				"-O3"
	# 				"-march=x86-64-v3"
	# 				"-fno-semantic-interposition"
	# 			];
	#
	# 			NIX_LDFLAGS = (oldAttrs.NIX_LDFLAGS or "");
	# 		});
	# 	})
	# ];

	nixpkgs.config.allowUnfree = true;

	environment.systemPackages = 
		let
		in
		[
			# pkgs.opencode
			# pkgs.qemu
			# Comment out ntfs3g bc we have boot option supportedfilesystems = ntfs now
			# pkgs.ntfs3g
			pkgs.wl-clipboard-rs
			pkgs.ghostty
			pkgs.vivaldi
			pkgs.discord
			pkgs.spotify
			pkgs.ddev
			pkgs.mkcert
			pkgs.xdg-utils
			pkgs.dbeaver-bin
			pkgs.php83
			pkgs.gcc
		];

	fonts.packages = [
		pkgs.fira-code
	];
}
