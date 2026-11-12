{ config, lib, pkgs, ... }:

let
  # darkman gira come servizio systemd utente, fuori da una sessione grafica
  # completa: gli schemi GSettings vanno quindi indicati esplicitamente.
  gsettingsSchemaDir = lib.concatStringsSep ":" [
    "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas"
    "${pkgs.glib}/share/glib-2.0/schemas"
  ];
in
{
  # Modulo nativo di home-manager: gestisce pacchetto, config.yaml,
  # script in $XDG_DATA_HOME/darkman e il servizio systemd utente.
  services.darkman = {
    enable = true;

    settings = {
      # Coordinate fisse (Roma): niente geoclue.
      lat = 41.8933;
      lng = 12.4829;
      usegeoclue = false;
      portal = true;
    };

    scripts."theme.sh" = ''
      export GSETTINGS_SCHEMA_DIR="${gsettingsSchemaDir}"
      export PATH="${lib.makeBinPath [ pkgs.glib pkgs.coreutils pkgs.gnused pkgs.gnugrep ]}:$PATH"

      # Aggiorna i settings.ini GTK (materializzati in scrittura dall'attivazione
      # qui sotto) così anche le app GTK che non leggono GSettings cambiano tema.
      update_gtk_ini() {
        local ini="$1" theme="$2" prefer="$3"
        [ -f "$ini" ] || return 0

        if grep -q '^gtk-theme-name=' "$ini"; then
          sed -i "s|^gtk-theme-name=.*|gtk-theme-name=$theme|" "$ini"
        else
          printf 'gtk-theme-name=%s\n' "$theme" >> "$ini"
        fi

        if grep -q '^gtk-application-prefer-dark-theme=' "$ini"; then
          sed -i "s|^gtk-application-prefer-dark-theme=.*|gtk-application-prefer-dark-theme=$prefer|" "$ini"
        else
          printf 'gtk-application-prefer-dark-theme=%s\n' "$prefer" >> "$ini"
        fi
      }

      # foot legge il tema da themes/current.ini: puntiamolo al file giusto.
      link_foot_theme() {
        local dir="$HOME/.config/foot/themes"
        [ -d "$dir" ] || return 0
        ln -sfn "$dir/$1.ini" "$dir/current.ini"
      }

      # rofi legge il tema da themes/current.rasi (vedi moduli/rofi.nix).
      link_rofi_theme() {
        local dir="$HOME/.config/rofi/themes"
        [ -d "$dir" ] || return 0
        ln -sfn "$dir/$1.rasi" "$dir/current.rasi"
      }

      case "$1" in
        dark)
          gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
          gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
          update_gtk_ini "$HOME/.config/gtk-3.0/settings.ini" "Adwaita-dark" 1
          update_gtk_ini "$HOME/.config/gtk-4.0/settings.ini" "Adwaita-dark" 1
          link_foot_theme dark
          link_rofi_theme dark
          ;;
        light)
          gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
          gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
          update_gtk_ini "$HOME/.config/gtk-3.0/settings.ini" "Adwaita" 0
          update_gtk_ini "$HOME/.config/gtk-4.0/settings.ini" "Adwaita" 0
          link_foot_theme light
          link_rofi_theme light
          ;;
      esac
    '';
  };

  # Home Manager crea i settings.ini GTK come symlink in sola lettura verso lo
  # store. darkman deve poterli modificare a runtime, quindi dopo il link li
  # sostituiamo con copie scrivibili. Poi riapplichiamo subito il tema della
  # modalità corrente, così uno switch di home-manager non lascia il desktop
  # nel tema sbagliato fino al prossimo cambio giorno/notte.
  home.activation.materializeGtkSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    for version in 3.0 4.0; do
      file="$HOME/.config/gtk-$version/settings.ini"
      if [ -L "$file" ]; then
        cp -- "$(readlink -f "$file")" "$file.hm-tmp"
        mv -f "$file.hm-tmp" "$file"
        chmod u+w "$file"
      fi
    done

    mode="$(${pkgs.darkman}/bin/darkman get 2>/dev/null || true)"
    case "$mode" in
      dark|light) ;;
      *) mode=dark ;;
    esac
    ${pkgs.bash}/bin/bash "$HOME/.local/share/darkman/theme.sh" "$mode" || true
  '';
}
