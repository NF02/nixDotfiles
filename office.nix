{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
		pkgs.libreoffice-qt
		pkgs.texliveFull
		pkgs.texstudio
		pkgs.gimp3
		pkgs.gimp3Plugins.gmic
    krita
    epson-escpr2
		pkgs.inkscape
		pkgs.scribus
		pkgs.svg2tikz
	];
}
