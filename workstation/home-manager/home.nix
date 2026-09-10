{ config, lib, pkgs, ... }:

{
  imports = [
    ./moduli/base.nix
    ./moduli/darkman.nix
    ./moduli/hyprpolkit.nix
    ./moduli/nushell.nix
    ./moduli/git.nix
    ./moduli/sbcl.nix
    ./moduli/i3bar.nix
    ./moduli/startw.nix
    ./moduli/emacs-config.nix
    ./moduli/sway-config.nix
    ./moduli/devicemenu.nix
    ./moduli/snipping.nix
    ./moduli/mpd.nix
    ./moduli/foot.nix
  ];

  programs.devicemenu.enable = true;
  programs.snipping.enable = true;
}
