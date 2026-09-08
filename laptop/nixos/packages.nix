{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    emacs
    firefox
    discord
    telegram-desktop
    libreoffice
    texmacs
    guile
    texliveFull
    nushell
    gimp
    darktable
    inkscape
    opencode
    cliphist
    obs-studio
    pavucontrol
    home-manager
  ];

}
