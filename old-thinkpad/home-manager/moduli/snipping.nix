{ config, lib, pkgs, ... }:

let
  cfg = config.programs.snipping;

  snipping-script = pkgs.writeShellScriptBin "snipping" ''
    #!/usr/bin/env bash
    set -u

    rofi=${cfg.rofi}
    grim=${cfg.grim}
    slurp=${cfg.slurp}
    swappy=${cfg.swappy}
    wl_copy=${cfg.wlCopy}
    swaymsg=${cfg.swaymsg}
    jq=${cfg.jq}
    notify_send=${cfg.notifySend}

    picture_dir="${cfg.pictureDir}"
    screenshot_dir="$picture_dir/screenshot"
    mkdir -p "$screenshot_dir"

    # slurp usa i "rettangoli predefiniti" se stdin non è un TTY.
    # Per area/schermo ci serve la selezione interattiva: se lo script
    # viene lanciato da Sway senza TTY, gliene diamo uno.
    slurp_interactive() {
      if [ -t 0 ]; then
        "$slurp" "$@"
      elif (exec </dev/tty) 2>/dev/null; then
        "$slurp" "$@" </dev/tty
      else
        "$slurp" "$@" </dev/null
      fi
    }

    choice=$(printf '%s\n' \
      'full screen' \
      'selection screen' \
      'selection area' \
      'selection window' \
      | "$rofi" -dmenu -p "Snipping tool")
    [ -n "$choice" ] || exit 0

    tmp_file=$(mktemp "''${TMPDIR:-/tmp}/snipping-XXXXXX")

    case "$choice" in
      "full screen")
        "$grim" "$tmp_file" || exit 1
        ;;
      "selection screen")
        output=$(slurp_interactive -o -f '%o') || exit 1
        [ -n "$output" ] || exit 1
        "$grim" -o "$output" "$tmp_file" || exit 1
        ;;
      "selection area")
        geometry=$(slurp_interactive) || exit 1
        [ -n "$geometry" ] || exit 1
        "$grim" -g "$geometry" "$tmp_file" || exit 1
        ;;
      "selection window")
        geometry=$(
          "$swaymsg" -t get_tree \
            | "$jq" -r '
                [.. | objects
                 | select(.pid? != null and .visible == true)
                 | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height) \(.name // "window")"]
                | .[]
              ' \
            | "$slurp" -r
        ) || exit 1
        [ -n "$geometry" ] || exit 1
        "$grim" -g "$geometry" "$tmp_file" || exit 1
        ;;
    esac

    [ -s "$tmp_file" ] || exit 1

    action=$(printf '%s\n' 'Edit screenshot' 'Save' 'Copy clipboard' \
      | "$rofi" -dmenu -p "Options:")
    [ -n "$action" ] || exit 0

    case "$action" in
      "Edit screenshot")
        "$swappy" -f "$tmp_file"
        ;;
      "Save")
        cp "$tmp_file" "$screenshot_dir/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"
        rm -f "$tmp_file"
        ;;
      "Copy clipboard")
        "$wl_copy" < "$tmp_file"
        rm -f "$tmp_file"
        ;;
    esac

    "$notify_send" "Snipping" "$action"
  '';
in
{
  options.programs.snipping = {
    enable = lib.mkEnableOption "snipping - rofi-based Wayland screenshot tool";

    rofi = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.rofi}/bin/rofi";
      description = "Path to rofi binary";
    };

    grim = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.grim}/bin/grim";
      description = "Path to grim binary";
    };

    slurp = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.slurp}/bin/slurp";
      description = "Path to slurp binary";
    };

    swappy = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.swappy}/bin/swappy";
      description = "Path to swappy binary";
    };

    wlCopy = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.wl-clipboard}/bin/wl-copy";
      description = "Path to wl-copy binary";
    };

    swaymsg = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.sway}/bin/swaymsg";
      description = "Path to swaymsg binary";
    };

    jq = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.jq}/bin/jq";
      description = "Path to jq binary";
    };

    notifySend = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.libnotify}/bin/notify-send";
      description = "Path to notify-send binary";
    };

    pictureDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Immagini";
      description = "Base directory where screenshots are saved";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      snipping-script
      pkgs.rofi
      pkgs.grim
      pkgs.slurp
      pkgs.swappy
      pkgs.wl-clipboard
      pkgs.sway
      pkgs.jq
      pkgs.libnotify
    ];
  };
}
