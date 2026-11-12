{ config, lib, pkgs, ... }:

{
  # È obbligatorio aggiornare questo valore in base alla versione di Home Manager che stai utilizzando.
  # Corrisponde alla release di NixOS (es. "26.11").
  home.stateVersion = "26.11";

  # Informazioni di base sull'utente
  home.username = "nick";
  home.homeDirectory = "/home/nick";
  nixpkgs.config.allowUnfree = true;
  
  fonts.fontconfig.enable = true;
  
  gtk = {
    enable = true;
    font = {
      name = "OpenDyslexic Nerd Font";
      size = 8;
    };
    theme = {
      # Baseline chiara: darkman applica subito dopo il tema della modalità
      # corrente (giorno/notte) sia a GSettings sia ai settings.ini GTK.
      name = "Adwaita";
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
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  qt = {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
  
  # Pacchetti di uso generale
  home.packages = with pkgs; [
    glib
    gh
    htop
    curl
    wget
    ripgrep
    fd
    gnumake
    automake
    pandoc
    font-awesome
    xdg-utils
  ];
  programs.opencode = {
    enable = true;
    mutableSettings = true;
    settings = { /* ... */ };
  };
  # Gestione autonoma dei servizi di Home Manager
  programs.home-manager.enable = true;
}
