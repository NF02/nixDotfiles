{ config, lib, pkgs, ... }:

let
  cfg = config.programs.devicemenu;

  devicemenu-script = pkgs.writeShellScriptBin "device-menu" ''
    #!/usr/bin/env bash

    mountmtp() {
        chosen="$(echo "$mtpdrives" | ${cfg.rofi} -dmenu -p "Which Android device?")" || exit 1
        tspace=$(echo $chosen | sed -r 's/( )+//g')
        mp="${cfg.mountDir}/$tspace/"
        chosen="$(echo "$chosen" | cut -d : -f 1)"
        mkdir -p $mp
        ${cfg.simpleMtpfs} --device "$chosen" "$mp"
        echo "OK" | ${cfg.rofi} -dmenu -p "Tap Allow on your phone if it asks for permission and then press enter" || exit 1
        ${cfg.simpleMtpfs} --device "$chosen" "$mp"
        ${cfg.notifySend} "Android Mounting" "Android device mounted to $mp."
    }

    mountusb() {
        chosen="$(echo "$usbdrives" | ${cfg.rofi} -dmenu -p "Mount which drive?")" || exit 1
        chosen="$(echo "$chosen" | awk '{print $1}')"
        ${cfg.udisksctl} mount -b $chosen && ${cfg.notifySend} "USB mounting" "$chosen mounted." && exit 0
    }

    asktype() {
        case $(printf "USB\nMTP" | ${cfg.rofi} -dmenu -p "Mount a USB drive or Android device?") in
            USB) mountusb ;;
            MTP) mountmtp ;;
        esac
    }

    unmountusb() {
        [ -z "$drives" ] && exit
        chosen=$(echo "$drives" | ${cfg.rofi} -dmenu -p "Unmount which drive?" | awk '{print $1}')
        [ -z "$chosen" ] && exit
        chosen="$(echo "$chosen" | awk '{print $1}')"
        ${cfg.udisksctl} unmount -b $chosen && ${cfg.notifySend} "USB unmounting" "$chosen unmounted."
    }

    unmountmtp() {
        chosen=$(awk '/simple-mtpfs/ {print $2}' /etc/mtab | ${cfg.rofi} -dmenu -p "Unmount which device?")
        [ -z "$chosen" ] && exit
        ${cfg.fusermount} -u "$chosen" && rmdir "$chosen" && ${cfg.notifySend} "Android unmounting" "$chosen unmounted."
    }

    unasktype() {
        case "$(printf "USB\nMTP" | ${cfg.rofi} -dmenu -p "Unmount a USB drive or Android device?")" in
            USB) unmountusb ;;
            MTP) unmountmtp ;;
        esac
    }

    if [[ $1 == --help ]] || [[ $1 == -h ]] || [[ $1 == -HELP ]]; then
        cat << 'EOF'
+-----------------------------------------------------------------+
| DDDD  EEEEE V   V III  CCC  EEEEE       M   M EEEEE N   N U   U |
| D   D E     V   V  I  C   C E           MM MM E     NN  N U   U |
| D   D EEEE  V   V  I  C     EEEE        M M M EEEE  N N N U   U |
| D   D E      V V   I  C   C E           M   M E     N  NN U   U |
| DDDD  EEEEE   V   III  CCC  EEEEE       M   M EEEEE N   N  UUU  |
+-----------------------------------------------------------------+

EOF
        exit 0
    fi

    opt=$(printf "mount\numount\n" | ${cfg.rofi} -dmenu -p "Device menu:")

    [ -z "$opt" ] && exit

    mtpdrives=$(${cfg.simpleMtpfs} -l 2>/dev/null)
    usbdrives=$(${cfg.lsblk} -rpo "name,type,size,mountpoint" | grep 'part\|rom' | awk '$4==""{printf "%s (%s)\n",$1,$3}')
    drives=$(${cfg.lsblk} -nrpo "name,type,size,mountpoint" | awk '$4!~/\/boot|\/home$|\/nix$|SWAP/&&length($4)>1{printf "%s (%s)\n",$1,$3}')

    case $opt in
        mount) asktype ;;
        umount) unasktype ;;
    esac
  '';
in
{
  options.programs.devicemenu = {
    enable = lib.mkEnableOption "devicemenu - rofi-based USB/MTP device menu";

    rofi = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.rofi}/bin/rofi";
      description = "Path to rofi binary";
    };

    simpleMtpfs = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.simple-mtpfs}/bin/simple-mtpfs";
      description = "Path to simple-mtpfs binary";
    };

    udisksctl = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.udisks2}/bin/udisksctl";
      description = "Path to udisksctl binary";
    };

    fusermount = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.fuse}/bin/fusermount";
      description = "Path to fusermount binary";
    };

    lsblk = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.util-linux}/bin/lsblk";
      description = "Path to lsblk binary";
    };

    notifySend = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.libnotify}/bin/notify-send";
      description = "Path to notify-send binary";
    };

    mountDir = lib.mkOption {
      type = lib.types.str;
      default = "$HOME";
      description = "Base directory where MTP devices are mounted";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      devicemenu-script
      pkgs.rofi
      pkgs.simple-mtpfs
      pkgs.udisks
      pkgs.fuse
      pkgs.util-linux
      pkgs.libnotify
    ];
  };
}
