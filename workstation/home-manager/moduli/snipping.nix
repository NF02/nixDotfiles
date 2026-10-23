{ config, lib, pkgs, ... }:

let
  cfg = config.programs.snipping;

  snipping-script = pkgs.writeShellScriptBin "snipping" ''
    #!/usr/bin/env bash

    # Options (catture automatizzate con hyprshot)
    opts="full screen\nselection area\nselection window\nactive window"
    snipping=$(printf "%b" "$opts" | ${cfg.launcher} --dmenu)
    if [[ -z "$snipping" ]]; then
        exit 0
    fi
    PICTURE_DIR="${cfg.pictureDir}"
    fileName="$(date +'%s_snipping.png')"
    actualFile="/tmp/$fileName"

    if [ ! -d "$PICTURE_DIR/screenshot" ]; then
        mkdir -p "$PICTURE_DIR/screenshot"
    fi

    # function
    opts_mod(){
        local file="$1"
        mods="Edit screenshot\nSave\nCopy clipboard"
        mods_la=$(printf "%b" "$mods" | ${cfg.launcher} --dmenu)
        case $mods_la in
            "Edit screenshot") ${cfg.swappy} -f "$file";;
            "Save") cp "$file" "$PICTURE_DIR/screenshot/";;
            "Copy clipboard") ${cfg.wlCopy} < "$file";;
            *) rm -f "$file"; exit 0;;
        esac
        rm -f "$file"
        ${cfg.notifySend} "Finish!"
    }

    capture(){
        ${cfg.hyprshot} -m $* -o /tmp -f "$fileName" -s || exit 1
        opts_mod "$actualFile"
    }

    # main program
    case $snipping in
        "full screen") capture output;;
        "selection area") capture region;;
        "selection window") capture window;;
        "active window") capture active -m window;;
    esac
  '';
in
{
  options.programs.snipping = {
    enable = lib.mkEnableOption "snipping - hyprshot-based Wayland screenshot tool with hyprlauncher menus";

    launcher = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.hyprlauncher}/bin/hyprlauncher";
      description = "Path to hyprlauncher binary";
    };

    hyprshot = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.hyprshot}/bin/hyprshot";
      description = "Path to hyprshot binary";
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

    notifySend = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.libnotify}/bin/notify-send";
      description = "Path to notify-send binary";
    };

    pictureDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/Immagini";
      description = "Base directory where screenshots are saved";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      snipping-script
      pkgs.hyprlauncher
      pkgs.hyprshot
      pkgs.swappy
      pkgs.wl-clipboard
      pkgs.libnotify
    ];
  };
}
