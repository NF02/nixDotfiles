{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    tuba
    afterglow-cursors-recolored
    adwaita-icon-theme
    nordzy-icon-theme
    gnomeExtensions.appindicator
    gnomeExtensions.krypto
    gnomeExtensions.ddterm
    gnomeExtensions.night-theme-switcher
    gnomeExtensions.blur-my-shell
    gnomeExtensions.dash-to-dock
    gnomeExtensions.gsconnect
    pkgs.gnomeExtensions.clipboard-indicator
    gnome-extension-manager
    gnomeExtensions.unite
    gnomeExtensions.easyeffects-preset-selector
    pkgs.rose-pine-icon-theme
  ];
  
  environment.gnome.excludePackages = (with pkgs; [
    atomix # puzzle game
    epiphany # web browser
    gedit # text editor
    gnome-music
    gnome-terminal
    hitori # sudoku game
    iagno # go game
    tali # poker game
    totem # video player
  ]);
}
