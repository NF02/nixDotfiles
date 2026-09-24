{ config, pkgs, lib, ... }:

{
  # Genera lo script "startw" per avviare Sway con l'ambiente corretto
  home.packages = [
    (pkgs.writeShellScriptBin "startw" ''
      if test -z "''${XDG_RUNTIME_DIR}"; then
        export XDG_RUNTIME_DIR=/tmp/''${UID}-runtime-dir
        if ! test -d "''${XDG_RUNTIME_DIR}"; then
          mkdir "''${XDG_RUNTIME_DIR}"
          chmod 0700 "''${XDG_RUNTIME_DIR}"
        fi
      fi

      # qt setting
      export QT_QPA_PLATFORMTHEME=qt5ct
      export QT_QPA_PLATFORM=wayland

      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_TYPE=wayland

      # acc. gpu
      export LIBVA_DRIVER_NAME=iHD

      # vaapi
      export VDPAU_DRIVER=va_gl

      # start desktop
      env XDG_CURRENT_DESKTOP=sway dbus-run-session sway
    '')
  ];
}