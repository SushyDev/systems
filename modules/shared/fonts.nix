{ pkgs, ... }:
{
	fonts = {
		packages = [
			pkgs.noto-fonts
			pkgs.noto-fonts-cjk-serif
			pkgs.noto-fonts-cjk-sans
			pkgs.noto-fonts-emoji
			pkgs.noto-fonts-extra
		];

		fontconfig = {
			enable = true;

			defaultFonts = {
				monospace = [ "Fira Code" "Noto Color Emoji" ];
				sansSerif = [ "DejaVu Sans" "Noto Color Emoji" ];
				serif = [ "DejaVu Serif" "Noto Color Emoji" ];
				emoji = [ "Noto Color Emoji" ];
			};
		};
	};
}
