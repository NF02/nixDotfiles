{ config, pkgs, ... }:

{
  # È obbligatorio aggiornare questo valore in base alla versione di Home Manager che stai utilizzando.
  # Corrisponde alla release di NixOS (es. "26.05").
  home.stateVersion = "26.05";

  # Informazioni di base sull'utente
  home.username = "nick";
  home.homeDirectory = "/home/nick";

  
  # Pacchetti da installare unicamente per l'utente corrente
  home.packages = with pkgs; [
    git
    htop
    curl
    wget
    ripgrep
    fd
    gnumake
    automake
		

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
  ];

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
  programs.emacs.package = pkgs.emacs-pgtk;
  programs.emacs = {
    enable = true;
    # Pacchetti Emacs gestiti nativamente da Nix (es. Magit, Vterm)
    extraPackages = epkgs: with epkgs; [
      # Gestione pacchetti e UI di base
      use-package
			nix-mode
      vertico
      marginalia
      doom-themes
      auto-dark
      doom-modeline
      nyan-mode
      company
      company-box
      all-the-icons
      which-key

      # Sviluppo e strumenti
      magit
      diff-hl
      eat
      neotree
      sly
      processing-mode
      
      # LaTeX e PDF
      cdlatex
      auctex
      pdf-tools
      
      # Org-mode ed estensioni
      nov
      
      # RSS
      elfeed
      elfeed-goodies
    ];
  };
  
  # Gestione autonoma dei servizi di Home Manager
  programs.home-manager.enable = true;
}
