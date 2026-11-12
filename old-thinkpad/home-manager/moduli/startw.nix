{ config, pkgs, lib, ... }:

{
  # Genera lo script "startw" per avviare Sway con l'ambiente corretto.
  home.packages = [
    (pkgs.writeShellScriptBin "startw" ''
      if test -z "''${XDG_RUNTIME_DIR}"; then
        export XDG_RUNTIME_DIR=/tmp/''${UID}-runtime-dir
        if ! test -d "''${XDG_RUNTIME_DIR}"; then
          mkdir "''${XDG_RUNTIME_DIR}"
          chmod 0700 "''${XDG_RUNTIME_DIR}"
        fi
      fi

      # Carica le variabili di sessione gestite da Home Manager.
      # Il guard evita di riapplicarle se la shell parent le ha già caricate;
      # qui lo azzeriamo per essere sicuri di partire sempre aggiornati.
      unset __HM_SESS_VARS_SOURCED
      if [ -r "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland

      # Usa il bus D-Bus del gestore utenti systemd (/run/user/UID/bus).
      # Con "dbus-run-session" si creava un bus privato: sway e le app di
      # sessione finivano su quel bus, mentre i servizi systemd utente
      # (Emacs, darkman.service, xdg-desktop-portal) restavano sul bus
      # systemd. Risultato: due istanze di darkman/portal e i cambi di tema
      # non arrivavano a Emacs via portal. Se il bus systemd non esiste,
      # manteniamo il vecchio fallback con un bus privato.
      if [ -S "''${XDG_RUNTIME_DIR}/bus" ]; then
        export DBUS_SESSION_BUS_ADDRESS="unix:path=''${XDG_RUNTIME_DIR}/bus"
        exec sway
      else
        exec dbus-run-session sway
      fi
    '')
  ];
}
