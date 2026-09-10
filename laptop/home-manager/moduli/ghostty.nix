{ config, pkgs, lib, ... }:

{
  # Ghostty terminal emulator
  programs.ghostty = {
    enable = true;
    settings = {
      theme = "light:light,dark:dark";
      font-family = "OpenDyslexicM Nerd Font Mono";
      font-size = 10;
      font-feature = "-liga";
    };

    themes = {
      dark = {
        background = "5d0c5a";
        foreground = "ffffff";
        cursor-color = "ffffff";
        selection-background = "c38ce7";
        selection-foreground = "ffffff";
        palette = [
          "0=#000000"
          "1=#d81860"
          "2=#5aa02c"
          "3=#d89824"
          "4=#4a93c4"
          "5=#9860a0"
          "6=#4ec9c0"
          "7=#d8d8d8"
        ];
      };
      light = {
        background = "fbf1c7";
        foreground = "202020";
        cursor-color = "202020";
        selection-background = "3070a0";
        selection-foreground = "ffffff";
        palette = [
          "0=#202020"
          "1=#b01050"
          "2=#408020"
          "3=#a07010"
          "4=#3070a0"
          "5=#704080"
          "6=#309080"
          "7=#d8d8d8"
        ];
      };
    };
  };
}