{ pkgs, ... }:
{
	fonts = {
		packages = [
			pkgs.noto-fonts
			pkgs.noto-fonts-cjk-serif
			pkgs.noto-fonts-cjk-sans
			pkgs.twitter-color-emoji
		];

		fontconfig = {
			enable = true;

		defaultFonts = {
			monospace = [ "Twitter Color Emoji" "Fira Code" ];
			sansSerif = [ "Twitter Color Emoji" "DejaVu Sans" ];
			serif = [ "Twitter Color Emoji" "DejaVu Serif" ];
			emoji = [ "Twitter Color Emoji" ];
		};
		};
	};
}
