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
			monospace = [ "Fira Code" "Twitter Color Emoji" ];
			sansSerif = [ "DejaVu Sans" "Twitter Color Emoji" ];
			serif = [ "DejaVu Serif" "Twitter Color Emoji" ];
			emoji = [ "Twitter Color Emoji" ];
		};
		};
	};
}
