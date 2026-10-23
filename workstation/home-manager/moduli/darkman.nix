{ config, pkgs, lib, ... }:

let
  # Ambiente per gli script di tema (gsettings) e per i servizi collegati.
  themeEnv = "PATH=${pkgs.glib}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gnused}/bin:${pkgs.gnugrep}/bin:${pkgs.systemd}/bin:/usr/bin:/bin GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share";

  # Script di tema: richiamato da darkman ad ogni cambio giorno/notte e,
  # via darkman-apply-theme, all'avvio della sessione grafica.
  themeScript = pkgs.writeShellScript "darkman-theme.sh" ''
    update_waybar() {
      local pref="$1"
      if [ "$pref" = "1" ]; then
        if [ -f "$HOME/.config/waybar/style-dark.css" ]; then
          rm -f "$HOME/.config/waybar/style.css"
          cp "$HOME/.config/waybar/style-dark.css" "$HOME/.config/waybar/style.css"
        fi
      else
        if [ ! -f "$HOME/.config/waybar/style-dark.css" ]; then
          cp "$HOME/.config/waybar/style.css" "$HOME/.config/waybar/style-dark.css"
        fi
        if [ -f "$HOME/.config/waybar/style-light.css" ]; then
          rm -f "$HOME/.config/waybar/style.css"
          cp "$HOME/.config/waybar/style-light.css" "$HOME/.config/waybar/style.css"
        fi
      fi
      chmod 644 "$HOME/.config/waybar/style.css" 2>/dev/null || true
      ${pkgs.systemd}/bin/systemctl --user restart waybar.service 2>/dev/null || ${pkgs.procps}/bin/pkill -SIGUSR2 waybar 2>/dev/null || true
    }

    update_prefer_dark() {
      local pref="$1"
      local ini="$2"
      mkdir -p "$(dirname "$ini")"
      if [ ! -f "$ini" ]; then
        printf '[Settings]\n' > "$ini"
      fi
      if ${pkgs.gnugrep}/bin/grep -q "gtk-application-prefer-dark-theme" "$ini"; then
        ${pkgs.gnused}/bin/sed -i "s/gtk-application-prefer-dark-theme.*/gtk-application-prefer-dark-theme='$pref/" "$ini"
      else
        echo "" >> "$ini"
        echo "gtk-application-prefer-dark-theme='$pref'" >> "$ini"
      fi
    }

    # Imposta una chiave GSettings di org.gnome.desktop.interface usando una
    # sessione D-Bus dedicata (darkman non eredita quella della sessione).
    set_gsettings() {
      ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon \
        ${pkgs.coreutils}/bin/env GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas \
        XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share \
        ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface "$1" "$2"
    }

    # Applica i wallpaper del tema indicato su tutti i monitor tramite
    # hyprpaper (ipc = on, vedi services.hyprpaper in hyprland.nix).
    # Preferisce le scelte fatte con wallpaper-picker
    # (~/.cache/bg per la luce, ~/.cache/bg-dark per il buio, righe
    # MONITOR=percorso); se
    # assenti o non valide, pesca un'immagine a caso dalla cartella del tema e
    # la salva nello stato, cosi' al prossimo switch il tema riprende la
    # stessa immagine invece di cambiarla ad ogni transizione.
    apply_wallpaper() {
      local theme="$1"
      local dir="$2"
      local stateDir="$HOME/.cache"
      mkdir -p "$stateDir"
      local state
      if [ "$theme" = "dark" ]; then
        state="$stateDir/bg-dark"
      else
        state="$stateDir/bg"
      fi
      local mon img i
      for mon in HDMI-A-2 DP-1; do
        img=""
        if [ -f "$state" ]; then
          img="$(${pkgs.gnugrep}/bin/grep "^$mon=" "$state" | ${pkgs.coreutils}/bin/head -n1 | ${pkgs.coreutils}/bin/cut -d= -f2-)"
        fi
        if [ -z "$img" ] || [ ! -f "$img" ]; then
          img="$(${pkgs.findutils}/bin/find "$dir" -type f \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.webp' \) 2>/dev/null | ${pkgs.coreutils}/bin/shuf -n 1)"
          if [ -n "$img" ]; then
            touch "$state"
            ${pkgs.gnugrep}/bin/grep -v "^$mon=" "$state" > "$state.tmp" 2>/dev/null || true
            echo "$mon=$img" >> "$state.tmp"
            ${pkgs.coreutils}/bin/mv "$state.tmp" "$state"
          fi
        fi
        if [ -n "$img" ] && [ -f "$img" ]; then
          # hyprpaper puo' non essere ancora pronto all'avvio sessione:
          # riprova per qualche secondo prima di mollare.
          for i in 1 2 3 4 5 6 7 8 9 10; do
            if ${pkgs.hyprland}/bin/hyprctl hyprpaper wallpaper "$mon,$img" >/dev/null 2>&1; then
              break
            fi
            ${pkgs.coreutils}/bin/sleep 1
          done
        fi
      done
    }

    case "$1" in
      dark)
        set_gsettings color-scheme prefer-dark
        set_gsettings gtk-theme Adwaita-dark
        update_prefer_dark 1 "$HOME/.config/gtk-3.0/settings.ini"
        update_prefer_dark 1 "$HOME/.config/gtk-4.0/settings.ini"
        update_waybar 1
        apply_wallpaper dark "/home/nick/Immagini/my-wallpapers/art"
        ;;
      light)
        set_gsettings color-scheme prefer-light
        set_gsettings gtk-theme Adwaita
        update_prefer_dark 0 "$HOME/.config/gtk-3.0/settings.ini"
        update_prefer_dark 0 "$HOME/.config/gtk-4.0/settings.ini"
        update_waybar 0
        apply_wallpaper light "/home/nick/Immagini/my-wallpapers/minimal"
        ;;
    esac
  '';

  # All'avvio della sessione darkman non esegue lo script (lo fa solo ai
  # cambi di modo): senza questo servizio resterebbe il wallpaper statico di
  # hyprpaper.conf, indipendente dal tema corrente.
  applyCurrentTheme = pkgs.writeShellScript "darkman-apply-current-theme" ''
    mode=""
    for i in 1 2 3 4 5 6 7 8 9 10; do
      mode="$(${pkgs.darkman}/bin/darkman get 2>/dev/null || true)"
      if [ -n "$mode" ]; then
        break
      fi
      ${pkgs.coreutils}/bin/sleep 1
    done
    exec ${themeScript} "''${mode:-dark}"
  '';
in
{
  # darkman: autoswitch tema chiaro/scuro in base a posizione solare
  home.packages = [ pkgs.darkman ];

  # Configurazione darkman: coordinate statiche per alba/tramonto (no geoclue).
  # Modifica lat/lng con la tua posizione per orari più precisi.
  xdg.configFile."darkman/config.yaml".text = ''
    lat: 41.8933
    lng: 12.4829
    usegeoclue: false
    portal: true
  '';

  # Script di cambio tema richiamato da darkman (arg: dark|light).
  # darkman cerca gli script eseguibili in $XDG_DATA_HOME/darkman
  # (default ~/.local/share/darkman).
  xdg.dataFile."darkman/theme.sh" = {
    executable = true;
    source = themeScript;
  };

  # Servizio systemd user darkman.
  # WantedBy graphical-session.target (e non default.target) e' fondamentale:
  # in quel modo parte dopo che Hyprland ha importato
  # HYPRLAND_INSTANCE_SIGNATURE/WAYLAND_DISPLAY nel manager systemd, altrimenti
  # hyprctl non trova l'IPC socket di Hyprland e il cambio wallpaper fallisce.
  systemd.user.services.darkman = {
    Unit = {
      Description = "Darkman - light and dark mode daemon";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "nl.whynothugo.darkman";
      ExecStart = "${pkgs.darkman}/bin/darkman run";
      Environment = themeEnv;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Applica il tema corrente (wallpaper incluso) all'avvio della sessione.
  systemd.user.services.darkman-apply-theme = {
    Unit = {
      Description = "Apply current dark/light theme at session start";
      After = [ "graphical-session.target" "darkman.service" "hyprpaper.service" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "oneshot";
      Environment = themeEnv;
      ExecStart = "${applyCurrentTheme}";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # Crea/gestisce i settings.ini di GTK3/GTK4 come file reali scrivibili (non symlink),
  # così darkman può aggiornarli a runtime con gtk-application-prefer-dark-theme.
  # Se i file non esistono, vengono creati con un baseline (font, tema, icone, cursor).
  home.activation.materializeGtkSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
    for v in 3.0 4.0; do
      f="$HOME/.config/gtk-$v/settings.ini"
      if [ -e "$f" ] && [ -L "$f" ]; then
        target="$(readlink "$f")"
        cp -- "$target" "$f.materialized" && mv -f "$f.materialized" "$f"
        chmod u+w "$f"
        echo "materialized $f"
      elif [ ! -e "$f" ]; then
        cat > "$f" <<'EOF'
[Settings]
gtk-cursor-theme-name=Adwaita
gtk-font-name=OpenDyslexic Nerd Font 10
gtk-icon-theme-name=Adwaita
gtk-theme-name=Adwaita-dark
EOF
        chmod u+w "$f"
        echo "created $f"
      fi
    done
  '';

# darkman espone il portale Settings per color-scheme (usato da Firefox/apps).
xdg.dataFile."xdg-desktop-portal/portals/darkman.portal" = {
  force = true;
  text = ''
    [portal]
    DBusName=org.freedesktop.impl.portal.desktop.darkman
    Interfaces=org.freedesktop.impl.portal.Settings
    UseIn=hyprland
  '';
};

xdg.configFile."xdg-desktop-portal/portals.conf" = {
  force = true;
  text = ''
    [preferred]
    default=hyprland;gtk
    org.freedesktop.impl.portal.Settings=darkman
  '';
};
}
