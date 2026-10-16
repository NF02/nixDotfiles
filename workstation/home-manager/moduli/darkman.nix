{ config, pkgs, lib, ... }:

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

  # Servizio systemd user darkman
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
      # gsettings, bash e gli schemi GSettings usati dagli script di tema
      Environment = "PATH=${pkgs.glib}/bin:${pkgs.bash}/bin:${pkgs.coreutils}/bin:${pkgs.gnused}/bin:${pkgs.gnugrep}/bin:${pkgs.systemd}/bin:/usr/bin:/bin GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "default.target" ];
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

      # Script di cambio tema lanciato da darkman (arg: dark|light).
      # darkman cerca gli script eseguibili in $XDG_DATA_HOME/darkman (default ~/.local/share/darkman).
      # Aggiorna color-scheme/gtk-theme via gsettings e gtk-application-prefer-dark-theme
      # negli settings.ini di GTK3/GTK4 (usato dalle app GTK in Wayland) e sincronizza la palette Wayle.
      xdg.dataFile."darkman/theme.sh" = {
        executable = true;
        text = ''
      #!/${pkgs.bash}/bin/bash

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
        ${pkgs.systemd}/bin/systemctl --user restart waybar.service 2>/dev/null || pkill -SIGUSR2 waybar 2>/dev/null || true
      }

      # Aggiorna o aggiunge gtk-application-prefer-dark-theme in settings.ini

      update_prefer_dark() {
        local pref="$1"
        local ini="$2"
        mkdir -p "$(dirname "''$ini")"
        if [ ! -f "''$ini" ]; then
          printf '[Settings]\n' > "''$ini"
        fi
        if grep -q "gtk-application-prefer-dark-theme" "''$ini"; then
          sed -i "s/gtk-application-prefer-dark-theme.*/gtk-application-prefer-dark-theme=''$pref/" "''$ini"
        else
          echo "" >> "''$ini"
          echo "gtk-application-prefer-dark-theme=''$pref" >> "''$ini"
        fi
      }

      case "''$1" in
        dark)
          ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon ${pkgs.coreutils}/bin/env GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
          ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon ${pkgs.coreutils}/bin/env GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
          update_prefer_dark 1 "$HOME/.config/gtk-3.0/settings.ini"
          update_prefer_dark 1 "$HOME/.config/gtk-4.0/settings.ini"
          update_waybar 1
          ;;
        light)
          ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon ${pkgs.coreutils}/bin/env GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface color-scheme "prefer-light"
          ${pkgs.dbus}/bin/dbus-run-session --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon ${pkgs.coreutils}/bin/env GSETTINGS_SCHEMA_DIR=${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}/glib-2.0/schemas:${pkgs.glib}/share/glib-2.0/schemas XDG_DATA_DIRS=${pkgs.gsettings-desktop-schemas}/share:${pkgs.dconf}/share:/run/current-system/sw/share:${pkgs.glib}/share ${pkgs.glib}/bin/gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
          update_prefer_dark 0 "$HOME/.config/gtk-3.0/settings.ini"
          update_prefer_dark 0 "$HOME/.config/gtk-4.0/settings.ini"
          update_waybar 0
          ;;
      esac    '';
  };

# darkman espone il portale Settings per color-scheme (usato da Firefox/apps).
xdg.dataFile."xdg-desktop-portal/portals/darkman.portal" = {
  force = true;
  text = ''
    [portal]
    DBusName=org.freedesktop.impl.portal.desktop.darkman
    Interfaces=org.freedesktop.impl.portal.Settings
    UseIn=hyprland;sway
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
