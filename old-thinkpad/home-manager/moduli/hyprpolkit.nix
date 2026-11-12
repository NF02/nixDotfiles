{ config, lib, pkgs, ... }:

{
  # hyprpolkitagent: agent di autenticazione polkit (sostituisce gnome_polkit,
  # che non funzionava). Funziona anche su altri compositor Wayland (sway).
  # Viene avviato dentro la sessione sway (vedi sway-config.nix) perché qui
  # WAYLAND_DISPLAY non è esposto al systemd user manager (sway parte via
  # dbus-run-session da startw).
  home.packages = [ pkgs.hyprpolkitagent ];
}