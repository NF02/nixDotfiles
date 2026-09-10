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
    scilab-bin
    openscad
    fastfetch
    kdePackages.ark
    opencode
    gimp
    inkscape
    darktable
    epson-escpr
    krita
    home-manager
  ];
}
