{ config, lib, pkgs, ... }:

{
  imports = [
    # Base e ambiente
    ./moduli/base.nix
    ./moduli/env.nix
    ./moduli/nushell.nix
    ./moduli/alacritty.nix
    ./moduli/git.nix

    # Desktop (Sway + componenti)
    ./moduli/sway-config.nix
    ./moduli/i3bar.nix
    ./moduli/startw.nix
    ./moduli/hyprpolkit.nix
    ./moduli/darkman.nix
    ./moduli/snipping.nix
    ./moduli/rofi.nix

    # Applicazioni
    ./moduli/emacs-config.nix
    ./moduli/sbcl.nix
  ];

  # Screenshot tool basato su rofi + grim/slurp/swappy (sostituisce Flameshot).
  programs.snipping.enable = true;
}
