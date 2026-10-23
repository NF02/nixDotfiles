{ config, lib, pkgs, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };
  
  # Aggiungi Wayle ai pacchetti di sistema (o del tuo utente)
  environment.systemPackages = with pkgs; [
    wayle
    rofi # Opzionale: per l'app launcher
    pavucontrol
    pcmanfm
    mpv
    mpd
    ncmpcpp
    udisks
    libnotify
    swaynotificationcenter
    waypaper
    wl-clipboard
    cliphist
    hyprpolkitagent
    playerctl
  ];

  programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland;

  services.hypridle.enable = true;
  programs.hyprlock.enable = true;
  

}
