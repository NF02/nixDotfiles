{ config, lib, pkgs, ... }:

let
  cfg = config.programs.devicemenu;

  devicemenu-script = pkgs.writeShellScriptBin "device-menu" ''
    #!/usr/bin/env bash

    mountmtp() {
        local mtpdrives
        mtpdrives=$(${cfg.lsusb} | grep -i -E "android|mtp|phone|media|samsung|google|xiaomi|huawei|apple" || ${cfg.lsusb})
        [ -z "$mtpdrives" ] && ${cfg.notifySend} "MTP" "Nessun dispositivo USB/MTP trovato." && exit 1

        chosen="$(echo "$mtpdrives" | ${cfg.launcher} --dmenu)" || exit 1
        
        # Estrae l'ID o nome dal dispositivo selezionato
        dev_id="$(echo "$chosen" | sed -E 's/ID ([0-9a-fA-F:]+).*/\1/')"
        tspace="$(echo "$chosen" | tr -d '[:punct:][:space:]')"
        mp="${cfg.mountDir}/$tspace"

        mkdir -p "$mp"

        # Esegue go-mtpfs usando il flag -dev corretto
        if ${cfg.mtpfs} -dev "$dev_id" "$mp"; then
            ${cfg.notifySend} "Android Mounting" "Dispositivo montato in $mp"
        else
            ${cfg.notifySend} "Android Mounting" "Errore durante il montaggio del dispositivo."
            rmdir "$mp" 2>/dev/null
        fi
        }

    mountusb() {
        local usbdrives
        usbdrives=$(${cfg.lsblk} -rpo "name,type,size,mountpoint" | grep -E 'part|rom' | awk '$4==""{printf "%s (%s)\n",$1,$3}')
        [ -z "$usbdrives" ] && ${cfg.notifySend} "USB" "Nessuna partizione USB da montare." && exit 1

        chosen="$(echo "$usbdrives" | ${cfg.launcher} --dmenu)" || exit 1
        chosen="$(echo "$chosen" | awk '{print $1}')"
        ${cfg.udisksctl} mount -b "$chosen" && ${cfg.notifySend} "USB mounting" "$chosen mounted." && exit 0
    }

    asktype() {
        case "$(printf "USB\nMTP" | ${cfg.launcher} --dmenu)" in
            USB) mountusb ;;
            MTP) mountmtp ;;
        esac
    }

    unmountusb() {
        local drives
        drives=$(${cfg.lsblk} -nrpo "name,type,size,mountpoint" | awk '$4!~/\/boot|\/home$|\/nix$|SWAP/&&length($4)>1{printf "%s (%s)\n",$1,$3}')
        [ -z "$drives" ] && ${cfg.notifySend} "USB" "Nessun dispositivo da smontare." && exit 1

        chosen="$(echo "$drives" | ${cfg.launcher} --dmenu | awk '{print $1}')"
        [ -z "$chosen" ] && exit 0

        ${cfg.udisksctl} unmount -b "$chosen" && ${cfg.notifySend} "USB unmounting" "$chosen unmounted."
    }

    unmountmtp() {
        chosen=$(awk '/go-mtpfs|simple-mtpfs/ {print $2}' /proc/mounts | ${cfg.launcher} --dmenu)
        [ -z "$chosen" ] && exit 0

        if ${cfg.fusermount} -u "$chosen"; then
            rmdir "$chosen" 2>/dev/null
            ${cfg.notifySend} "Android unmounting" "$chosen unmounted."
        fi
    }

    unasktype() {
        case "$(printf "USB\nMTP" | ${cfg.launcher} --dmenu)" in
            USB) unmountusb ;;
            MTP) unmountmtp ;;
        esac
    }

    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
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

    opt=$(printf "mount\numount\n" | ${cfg.launcher} --dmenu)

    case "$opt" in
        mount) asktype ;;
        umount) unasktype ;;
    esac
  '';
in
{
  options.programs.devicemenu = {
    enable = lib.mkEnableOption "devicemenu - hyprlauncher-based USB/MTP device menu";

    launcher = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.hyprlauncher}/bin/hyprlauncher";
      description = "Path to hyprlauncher binary";
    };

    mtpfs = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.go-mtpfs}/bin/go-mtpfs";
      description = "Path to go-mtpfs binary";
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

    lsusb = lib.mkOption {
      type = lib.types.path;
      default = "${pkgs.usbutils}/bin/lsusb";
      description = "Path to lsusb binary";
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
      pkgs.hyprlauncher
      pkgs.go-mtpfs
      pkgs.udisks2
      pkgs.fuse
      pkgs.util-linux
      pkgs.usbutils
      pkgs.libnotify
    ];
  };
}
