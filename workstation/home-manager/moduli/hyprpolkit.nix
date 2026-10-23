{ config, lib, pkgs, ... }:

{
  # hyprpolkitagent: agent di autenticazione polkit (sostituisce gnome_polkit,
  # che non funzionava).
  # Viene avviato dalla sessione Hyprland tramite services.hyprpolkitagent
  # (vedi hyprland.nix), che espone WAYLAND_DISPLAY al servizio systemd user.
  home.packages = [ pkgs.hyprpolkitagent ];
}
