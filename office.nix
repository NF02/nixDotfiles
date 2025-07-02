{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
		libreoffice-still
		pkgs.texliveFull
		pkgs.texstudio
		pkgs.gimp3
		pkgs.gimp3Plugins.gmic
    krita
    epson-escpr2
		pkgs.inkscape
		pkgs.scribus
		pkgs.svg2tikz
    xournalpp
    
	];
  services.printing.drivers = [ pkgs.epson-escpr2 ];
}
