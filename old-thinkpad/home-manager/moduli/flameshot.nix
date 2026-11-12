{ config, lib, pkgs, ... }:

let
  iniFormat = pkgs.formats.ini { };
in
{
  # Flameshot 14 supporta Wayland tramite xdg-desktop-portal e sostituisce
  # lo script "snipping" basato su grim/slurp/swappy.
  # Non usiamo services.flameshot: il suo demone systemd parte senza
  # WAYLAND_DISPLAY (e qui non c'è un tray), mentre `flameshot gui` funziona
  # benissimo avviato dal keybinding di Sway.
  home.packages = [ pkgs.flameshot ];

  xdg.configFile."flameshot/flameshot.ini" = {
    force = true;
    source = iniFormat.generate "flameshot.ini" {
      General = {
        savePath = "${config.home.homeDirectory}/Immagini/screenshot";
        saveAsFileExtension = ".png";
        showStartupLaunchMessage = false;
      };
    };
  };

  home.activation.createScreenshotDir = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "$HOME/Immagini/screenshot"
  '';
}
