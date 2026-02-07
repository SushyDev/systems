{ pkgs, ... }:
{
	imports = [ ../../shared/nix.nix ];

	programs.nix-ld.libraries = [ pkgs.fnm ];
}
