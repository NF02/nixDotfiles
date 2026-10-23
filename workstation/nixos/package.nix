{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
   	emacs-pgtk
   	texmacs
   	libreoffice
   	git
   	gh
    kdePackages.okular
   	nushell
   	calibre
    obs-studio
    shotcut
    texliveFull
    maxima
    telegram-desktop
    discord
    julia
    openscad
    fastfetch
    kdePackages.ark
    ghostty
    gimp
    inkscape
    darktable
    epson-escpr
    krita
    home-manager
  ];
  
}
