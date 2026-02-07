{ pkgs, ... }:
{
	environment.systemPackages = [
		pkgs.vim
		pkgs.jq
		pkgs.gitMinimal
	];
}
