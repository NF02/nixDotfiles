{ config, pkgs, ... }:

{
	environment.systemPackages = with pkgs; [
   	emacs-pgtk
   	texmacs
   	libreoffice
   	git
   	gh
   	cargo
   	sbcl
   	gnucobol
   	nushell
   	evolution
   	calibre
   	evince
    obs-studio
    pitivi
    texliveFull
    maxima
    texstudio
    gnumake
    scilab-bin
    openscad
    fastfetch
    file-roller
    opencode
    home-manager
  ];
}
