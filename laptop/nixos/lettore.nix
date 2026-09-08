{ config, pkgs, lib, ... }:

let
  # Percorso locale dei firmware
  firmwareDir = /var/lib/fprint/fw;

  # Derivazione che contiene i firmware completi (inclusi i .otp Unassigned)
  broadcomFwStore = pkgs.stdenv.mkDerivation {
    name = "broadcom-firmware-patched";
    src = firmwareDir;
    phases = [ "installPhase" ];
    installPhase = ''
      mkdir -p $out/var/lib/fprint/fw
      mkdir -p $out/lib/fprint/fw

      # Copia i file dereferenziando i symlink
      cp -rL $src/* $out/var/lib/fprint/fw/ 2>/dev/null || true

      # Genera i file Unassigned se non presenti
      cd $out/var/lib/fprint/fw/
      if [ ! -f "bcmsbiCitadelA0_Unassigned.otp" ] && [ -f "bcmsbiCitadelA0_1.otp" ]; then
        cp bcmsbiCitadelA0_1.otp bcmsbiCitadelA0_Unassigned.otp
      fi
      if [ ! -f "bcmCitadel_Unassigned.otp" ] && [ -f "bcmCitadel_1.otp" ]; then
        cp bcmCitadel_1.otp bcmCitadel_Unassigned.otp
      fi

      cp -r * $out/lib/fprint/fw/ 2>/dev/null || true
    '';
  };
in
{
  # Abilitazione del servizio fprintd con driver Broadcom standard
  services.fprintd = {
    enable = true;
    tod.enable = true;
    tod.driver = pkgs.libfprint-2-tod1-broadcom;
  };

  # Configurazione systemd con reindirizzamento dei vecchi Store Path
  systemd.services.fprintd = {
    environment = {
      "CV_POWER_MANAGEMENT" = "0";
      "G_MESSAGES_DEBUG" = "all";
    };
    serviceConfig = {
      # Mappiamo la nuova derivazione firmware sia su /var/lib/fprint/fw
      # sia su qualunque vecchio store path hardcodato cercato dalla wrapper-lib
      BindReadOnlyPaths = [
        "${broadcomFwStore}/var/lib/fprint/fw:/var/lib/fprint/fw"
        "${broadcomFwStore}/var/lib/fprint/fw:${pkgs.libfprint-2-tod1-broadcom}/var/lib/fprint/fw"
      ];
      ReadWritePaths = [ "/var/lib/fprint" ];
      ProtectSystem = lib.mkForce "false";
      ProtectHome = lib.mkForce "false";
    };
  };

  # Regole Udev e TLP per la gestione energetica
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{idVendor}=="0a5c", ATTR{idProduct}=="5843", ATTR{power/control}="on", ATTR{power/autosuspend_delay_ms}="-1", ATTR{power/persist}="0"
  '';

  services.tlp.settings = {
    USB_EXCLUDE_BOOT = "0a5c:5843";
    USB_DENYLIST = "0a5c:5843";
    USB_AUTOSUSPEND = 0;
  };

  # Regole Polkit per l'autenticazione utente
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "net.reactivated.fprint.device.enroll" ||
           action.id == "net.reactivated.fprint.device.verify") &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  # Reset del dispositivo USB al resume dalla sospensione
  systemd.services.fprintd-resume-fix = {
    description = "Reset ControlVault USB e restart fprintd";
    after = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    wantedBy = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" ];
    path = [ pkgs.usbutils pkgs.coreutils pkgs.bash ];
    script = ''
      for dev in /sys/bus/usb/devices/*; do
        if [ -f "$dev/idVendor" ] && [ -f "$dev/idProduct" ]; then
          if [ "$(cat $dev/idVendor)" = "0a5c" ] && [ "$(cat $dev/idProduct)" = "5843" ]; then
            echo 0 > "$dev/authorized"
            sleep 0.2
            echo 1 > "$dev/authorized"
            break
          fi
        fi
      done
      ${pkgs.systemd}/bin/systemctl restart fprintd.service
    '';
    serviceConfig = {
      Type = "oneshot";
    };
  };
}
