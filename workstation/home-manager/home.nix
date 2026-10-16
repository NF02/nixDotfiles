{ config, lib, pkgs, ... }:

{
  imports = [
    ./moduli/base.nix
    ./moduli/darkman.nix
    ./moduli/hyprpolkit.nix
    ./moduli/nushell.nix
    ./moduli/git.nix
    ./moduli/sbcl.nix
    ./moduli/emacs-config.nix
    ./moduli/devicemenu.nix
    ./moduli/snipping.nix
    ./moduli/mpd.nix
    ./moduli/mime.nix
    ./moduli/ghostty.nix
    ./moduli/hyprland.nix
    ./moduli/hyprlock.nix
    ./moduli/hypridle.nix
    ./moduli/waybar.nix
  ];
  programs.devicemenu.enable = true;
  programs.snipping.enable = true;
}
