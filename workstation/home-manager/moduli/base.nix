{ config, lib, pkgs, ... }:

{
  # È obbligatorio aggiornare questo valore in base alla versione di Home Manager che stai utilizzando.
  # Corrisponde alla release di NixOS (es. "26.05").
  home.stateVersion = "26.05";

  nixpkgs.config.allowUnfree = true;
  # Informazioni di base sull'utente
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  fonts.fontconfig.enable = true;

  gtk = {
    enable = true;
    font = {
      name = "OpenDyslexic Nerd Font";
      size = 8;
    };
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 0;
    };
  };

  qt.platformTheme = {
    qt.platformTheme = "gnome";
  };
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  
  # Pacchetti di uso generale
  home.packages = with pkgs; [
    glib
    htop
    opencode
    curl
    wget
    ripgrep
    fd
    pandoc
    font-awesome
    corefonts
    typst
    gcc
    # musica
    guitarix
    ardour
    musescore
    audacity
    lmms-full
    R
    (pkgs.rWrapper.override {
      packages = with rPackages; [
        tidyverse
        ggplot2
        dplyr
        languageserver
      ];
    })
  ];
  # Gestione autonoma dei servizi di Home Manager
  programs.home-manager.enable = true;
}
