{ config, lib, pkgs, ... }:

let
  cfg = config.programs.wallpaperpicker;

  monitorsArgs = lib.concatMapStringsSep "\\n" (m: m) cfg.monitors;

  wallpaperpicker-script = pkgs.writeShellScriptBin "wallpaper-picker" ''
    #!/usr/bin/env bash

    stateDir="${cfg.stateDir}"
    mkdir -p "$stateDir"

    current="$(${cfg.darkman} get 2>/dev/null || echo dark)"

    # Scelta immagine con yazi (scrive il percorso selezionato nel chooser file)
    chooser="$(mktemp -u /tmp/yazi-chooser.XXXXXX)"
    ${cfg.yazi} --chooser-file "$chooser" "${cfg.startDir}"
    img="$(head -n 1 "$chooser" 2>/dev/null)"
    rm -f "$chooser"
    if [[ -z "$img" ]] || [[ ! -f "$img" ]]; then
        exit 0
    fi

    # Scelta del monitor (il launcher puo' stampare messaggi d'errore invece
    # della selezione: validiamo che sia un monitor reale)
    mon=$(printf "%b" "${monitorsArgs}" | ${cfg.launcher} --dmenu)
    if ! printf "%b" "${monitorsArgs}" | ${pkgs.gnugrep}/bin/grep -Fxq "$mon"; then
        exit 0
    fi

    # Scelta del tema a cui associare il wallpaper (stessa validazione)
    slot=$(printf "dark\nlight" | ${cfg.launcher} --dmenu)
    if [[ "$slot" != "dark" && "$slot" != "light" ]]; then
        exit 0
    fi

    # Persistenza: ~/.cache/bg (light) o ~/.cache/bg-dark (dark),
    # righe MONITOR=percorso
    if [[ "$slot" == "dark" ]]; then
        state="$stateDir/bg-dark"
    else
        state="$stateDir/bg"
    fi
    touch "$state"
    ${pkgs.gnugrep}/bin/grep -v "^$mon=" "$state" > "$state.tmp" || true
    echo "$mon=$img" >> "$state.tmp"
    ${pkgs.coreutils}/bin/mv "$state.tmp" "$state"

    # Applica subito solo se il tema scelto e' quello corrente
    if [[ "$slot" == "$current" ]]; then
        ${cfg.hyprctl} hyprpaper wallpaper "$mon,$img"
    fi

    base="$(${pkgs.coreutils}/bin/basename "$img")"
    ${cfg.notifySend} "Wallpaper ($slot)" "$mon <- $base"
  '';
in
{
  options.programs.wallpaperpicker = {
    enable = lib.mkEnableOption "wallpaper-picker - scegli wallpaper con yazi e applicalo con hyprpaper";

    launcher = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.hyprlauncher}/bin/hyprlauncher";
      description = "Path to hyprlauncher binary";
    };

    yazi = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.yazi}/bin/yazi";
      description = "Path to yazi binary";
    };

    hyprctl = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.hyprland}/bin/hyprctl";
      description = "Path to hyprctl binary";
    };

    darkman = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.darkman}/bin/darkman";
      description = "Path to darkman binary";
    };

    notifySend = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.libnotify}/bin/notify-send";
      description = "Path to notify-send binary";
    };

    startDir = lib.mkOption {
      type = lib.types.str;
      default = "/home/nick/Immagini";
      description = "Directory di partenza di yazi";
    };

    monitors = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "HDMI-A-2" "DP-1" ];
      description = "Monitor selezionabili per il wallpaper";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.cache";
      description = "Directory di stato: ~/.cache/bg (light) e ~/.cache/bg-dark (dark), righe MONITOR=immagine";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      wallpaperpicker-script
      pkgs.yazi
      pkgs.hyprlauncher
      pkgs.libnotify
    ];
  };
}
