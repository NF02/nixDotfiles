{ config, pkgs, ... }:

{
  # È obbligatorio aggiornare questo valore in base alla versione di Home Manager che stai utilizzando.
  # Corrisponde alla release di NixOS (es. "26.05").
  home.stateVersion = "26.05";

  # Informazioni di base sull'utente
  home.username = "nick";
  home.homeDirectory = "/home/nick/";
  imports = [
    ./moduli/table.nix
    ./moduli/sway-config.nix
    ./moduli/i3bar.nix
    ./moduli/startw.nix
    ./moduli/emacs-config.nix
  ];
  
  # Pacchetti da installare unicamente per l'utente corrente
  home.packages = with pkgs; [
    git
    gh
    htop
    curl
    wget
    ripgrep
    fd
    gnumake
    automake
    processing
    
    # --- Dipendenze per Emacs e pacchetti correlati ---
    hunspell                 # Necessario per ispell / flyspell
    hunspellDicts.it-it      # Dizionario italiano per hunspell (consigliato)
    sbcl                     # Steel Bank Common Lisp per SLY
    clang-tools              # Include clangd per Eglot (C/C++)
    texlab                   # Server LSP per LaTeX
    phpactor                 # Server LSP per PHP
    lilypond                 # Compilatore per spartiti musicali
    pandoc                   # Per l'export avanzato in org-mode
    libarchive               # Richiesto da nov.el per la gestione degli EPUB
    
    # Font configurato in gui.el
    nerd-fonts.open-dyslexic
    font-awesome
    emacs-all-the-icons-fonts  # Font per all-the-icons/company-box/org-roam-ui (visibili grazie a fonts.fontconfig)
  ];

  # Rende i font installati via home.packages visibili a fontconfig (Emacs, barra, ecc.)
  fonts.fontconfig.enable = true;

  # Gestione dichiarativa di Nushell (ora integrata correttamente tramite Home Manager)
  programs.nushell = {
    enable = true;
    settings = {
      show_banner = false;
    };
    shellAliases = {
      g = "git";
      ll = "ls -l";
      rm = "rm --trash";
      
    };
  };

  # Configurazione di Git di base
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Nicola Ferru";
        email = "ask.nfvblog@outlook.it";
      };
    };
  };
  systemd.user.services.polkit-gnome-agent = {
    Unit = {
      Description = "GNOME Polkit Authentication Agent";
      WantedBy = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
  
  # Gestione autonoma dei servizi di Home Manager
  programs.home-manager.enable = true;
}
