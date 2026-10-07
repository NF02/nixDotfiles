{ config, pkgs, lib, ... }:

let
  emacsPackagesList = epkgs: with epkgs; [
    # --- Core e UI (init.el, gui.el) ---
    use-package
    nix-mode
    vertico
    marginalia
    doom-themes
    auto-dark
    doom-modeline
    nyan-mode
    all-the-icons
    company
    company-box
    which-key

    # --- Sviluppo (lisp/dev.el) ---
    eat
    neotree
    sly
    processing-mode
    cobol-mode

    # --- Web (lisp/web.el) ---
    web-mode
    emmet-mode
    php-mode
    hugoista

    # --- LaTeX e PDF (lisp/latex-conf.el) ---
    cdlatex
    auctex
    pdf-tools

    # --- Org-mode ed estensioni (lisp/org-conf.el) ---
    org-modern
    org-fragtog
    org-roam
    org-roam-ui
    org-super-agenda
    visual-fill-column
    org-tree-slide
    ox-pandoc
    nov

    # --- Git (lisp/git.el) ---
    magit
    diff-hl

    # --- RSS (lisp/rss.el) ---
    elfeed
    elfeed-goodies

    # --- Typst (lisp/typst.el) ---
    typst-ts-mode

    # --- Scribble/Racket (lisp/scribble.el) ---
    racket-mode
  ];
in
{
  # ------------------------------------------------------------------
  # Emacs: editor, pacchetti e server
  # Specchia la struttura di ~/.emacs.d/
  # ------------------------------------------------------------------
  home.packages = with pkgs; [
    processing
    hunspell                 # Necessario per ispell / flyspell
    hunspellDicts.it-it      # Dizionario italiano per hunspell (consigliato)
    clang-tools              # Include clangd per Eglot (C/C++)
    texlab                   # Server LSP per LaTeX
    phpactor                 # Server LSP per PHP
    lilypond                 # Compilatore per spartiti musicali
    pandoc                   # Per l'export avanzato in org-mode
    libarchive               # Richiesto da nov.el per la gestione degli EPUB
    python314Packages.weasyprint
    tree-sitter-grammars.tree-sitter-typst

    # Font configurato in gui.el
    nerd-fonts.open-dyslexic
    nerd-fonts.hurmit
    nerd-fonts.iosevka-term
    nerd-fonts.symbols-only
    emacs-all-the-icons-fonts  # Font per all-the-icons/company-box/org-roam-ui (visibili grazie a fonts.fontconfig)
  ];

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = emacsPackagesList;
  };

  # --- Emacs server (daemon attivato dal socket, usato da emacsclient) ---
  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
    defaultEditor = true;
  };
}
