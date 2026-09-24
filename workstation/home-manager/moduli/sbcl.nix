{ config, lib, pkgs, ... }:

{
  # Steel Bank Common Lisp per SLY + Graphviz richiesto da cl-obelisk
  home.packages = with pkgs; [
    sbcl
    graphviz
  ];

  # Il file di config di SBCL carica Quicklisp all'avvio (se presente)
  home.file.".sbclrc".text = ''
    ;;;; ~/.sbclrc

    ;;; 1. QUICKLISP INTEGRATION
    ;;; Automatically loads Quicklisp if present
    #-quicklisp
    (let ((quicklisp-init (merge-pathnames "quicklisp/setup.lisp" (user-homedir-pathname))))
      (when (probe-file quicklisp-init)
        (load quicklisp-init)))

    ;;; 2. FIX FOR GTK4 / WAYLAND / GRAPHICS DRIVERS
    ;;; Disables floating-point traps to avoid issues with GTK4 on certain systems
    #+sbcl
    (sb-int:set-floating-point-modes :traps nil)

    ;;; 3. COMPILER OPTIMIZATION
    ;;; Prioritizes debug info and safety during development over speed
    (declaim (optimize (debug 3) (speed 1) (safety 3)))

    ;;; 4. UTILITY PACKAGE FOR REPL CONVENIENCE
    (defpackage :sbcl-user-utils
    	    (:use :cl))

    (in-package :cl-user) ;; Optional: use this if you're working with Emacs solutions like SLY or SLIME

    ;;; 5. CUSTOM WELCOME MESSAGE
    (require :asdf)
    (format t "~%--- SBCL (the most despotic Lisp machine ever created) ---~%")
    (format t "Display: ~A~%" (uiop:getenv "WAYLAND_DISPLAY"))
  '';

  # Script di attivazione: installa Quicklisp in ~/quicklisp e clona cl-obelisk nei local-projects (idempotente)
  home.activation.quicklisp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/quicklisp/setup.lisp" ]; then
      run ${pkgs.curl}/bin/curl -fsSL https://beta.quicklisp.org/quicklisp.lisp -o /tmp/quicklisp-installer.lisp
      run ${pkgs.sbcl}/bin/sbcl --non-interactive --load /tmp/quicklisp-installer.lisp --eval '(quicklisp-quickstart:install)'
      run rm -f /tmp/quicklisp-installer.lisp
    fi

    # Clona cl-obelisk nei local-projects di Quicklisp se non già presente
    if [ ! -d "$HOME/quicklisp/local-projects/cl-obelisk" ]; then
      mkdir -p "$HOME/quicklisp/local-projects"
      run ${pkgs.git}/bin/git clone https://github.com/NF02/cl-obelisk.git "$HOME/quicklisp/local-projects/cl-obelisk"
    fi
  '';
}