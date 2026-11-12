{ config, lib, pkgs, ... }:

let
  cfg = config.programs.snipping;

  snipping-script = pkgs.writeShellScriptBin "snipping" ''
    #!/usr/bin/env bash

    # Options
    opts="full screen\nselection screen\nselection area\nselection window"
    snipping=$(echo -e $opts | ${cfg.rofi} -dmenu -p "Snipping tool")
    if [[ $snipping == "" ]]; then
        exit 0
    fi
    PICTURE_DIR="${cfg.pictureDir}"
    temp="/tmp"
    fileName=$(echo "$temp/$(date +'%s_grim.png')")

    if [ ! -d "$PICTURE_DIR/screenshot" ];then
        mkdir -p $PICTURE_DIR/screenshot/
    fi

    # function
    opts_mod(){
        mods="Edit screenshot\nSave\nCopy clipboard\n"
        mods_la=$(echo -e $mods | ${cfg.rofi} -dmenu -p "Options:")
        if [[ $mods_la == "" ]]; then
            exit 0
        fi

        case $mods_la in
            "Edit screenshot") ${cfg.swappy} -f $1;;
            "Save") cp $1 $PICTURE_DIR/screenshot/;;
            "Copy clipboard") ${cfg.wlCopy} < $1;;
        esac
        ${cfg.notifySend} "Finish!"
    }

    full_screen(){
        actualFile=$fileName
        ${cfg.grim} $actualFile
        opts_mod "$actualFile"
    }

    selection_screen(){
        actualFile=$fileName
        ${cfg.grim} -o $(${cfg.slurp} -f %o -or) $actualFile
        opts_mod "$actualFile"
    }

    selection_area(){
        actualFile=$fileName
        ${cfg.grim} -g "$(${cfg.slurp})" $actualFile
        opts_mod "$actualFile"
    }

    ## window selection
    function select_window() {
        local clients=`${cfg.swaymsg} -t get_tree | ${cfg.jq} -r '[.. | ((.nodes? // empty) + (.floating_nodes? // empty))[] | select(.visible and .pid)]'`
        local boxes="$(echo $clients | ${cfg.jq} -r '.[] | "\(.rect.x),\(.rect.y) \(.rect.width)x\(.rect.height) \(.name)"')"
        ${cfg.slurp} -r <<< "$boxes"
    }

    selection_active_window(){
        actualFile=$fileName
        ${cfg.grim} -g "$(select_window)" $actualFile
        opts_mod "$actualFile"
    }

    # main program
    case $snipping in
        "full screen") full_screen;;
        "selection screen") selection_screen;;
        "selection area") selection_area;;
        "selection window") selection_active_window;;
    esac
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
      default = "$HOME/Immagini";
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
