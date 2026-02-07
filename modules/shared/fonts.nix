{ pkgs, ... }:
{
	fonts = {
		packages = with pkgs; [
			noto-fonts
			noto-fonts-cjk-serif
			noto-fonts-cjk-sans
			noto-fonts-emoji
			noto-fonts-extra
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
