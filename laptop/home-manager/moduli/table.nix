{ config, pkgs, ... }:

let
  toggleTabletMode = pkgs.writeShellApplication {
    name = "toggle-tablet-mode";

    # Pacchetti necessari per l'esecuzione dello script
    runtimeInputs = with pkgs; [
      sway
      jq
      psmisc # per killall e pgrep
      rot8   # gestore rotazione schermo
      wvkbd  # tastiera a schermo
    ];

    text = ''
      BAR_DEFAULT_ID="bar_default"
      BAR_TABLET_ID="bar_tablet"

      # Interroga lo stato della barra tablet
      CURRENT_MODE=$(swaymsg -t get_bar_config "$BAR_TABLET_ID" | jq -r '.mode')

      if [ "$CURRENT_MODE" == "invisible" ]; then
          echo "Attivazione Modalità Tablet..."

          # 1. Barre
          swaymsg bar "$BAR_DEFAULT_ID" mode invisible
          swaymsg bar "$BAR_TABLET_ID" mode dock

          # 2. Layout
          swaymsg layout tabbed

          # 3. Processi in background
          pgrep rot8 > /dev/null || rot8 &
          pgrep wvkbd > /dev/null || wvkbd-mobintl -L 240 &

          echo "Modalità Tablet Attivata."
      else
          echo "Attivazione Modalità Laptop..."

          # 1. Barre
          swaymsg bar "$BAR_DEFAULT_ID" mode dock
          swaymsg bar "$BAR_TABLET_ID" mode invisible

          # 2. Processi in background
          killall -q rot8 || true
          killall -q wvkbd-mobintl || true

          # 3. Layout (ripristina layout split standard)
          swaymsg layout split

          echo "Modalità Laptop Attivata."
      fi
    '';
  };
in
{
  # Aggiunge lo script ai pacchetti utente
  home.packages = [
    toggleTabletMode
    pkgs.rot8
    pkgs.wvkbd
  ];

  # Mappatura della scorciatoia da tastiera in Sway ($mod + Shift + t)
  wayland.windowManager.sway.config.keybindings = {
    "${config.wayland.windowManager.sway.config.modifier}+Shift+t" = "exec toggle-tablet-mode";
  };
}
