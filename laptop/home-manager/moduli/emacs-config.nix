{ config, pkgs, lib, ... }:

{
  # ------------------------------------------------------------------
  # Emacs: editor, pacchetti e server
  # Specchia la struttura di ~/.emacs.d/
  # ------------------------------------------------------------------

  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    # Pacchetti Emacs gestiti nativamente da Nix (installati ad ogni avvio)
    extraPackages = epkgs: with epkgs; [
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
  };

  # --- Emacs server (daemon attivato dal socket, usato da emacsclient) ---
  services.emacs = {
    enable = true;
    client.enable = true;
    socketActivation.enable = true;
    defaultEditor = true;
  };
}
