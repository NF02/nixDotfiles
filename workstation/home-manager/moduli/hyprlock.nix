{ config, lib, pkgs, ... }:

{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      label = [
        {
          monitor = "";
          text = "$TIME";
          font_size = 90;
          font_family = "OpenDyslexic Nerd Font";
          position = "-30, 0";
          halign = "right";
          valign = "top";
        }
        {
          monitor = "";
          text = ''cmd[update:60000] date +"%A, %d %B %Y"'';
          font_size = 25;
          font_family = "OpenDyslexic Nerd Font";
          position = "-30, -150";
          halign = "right";
          valign = "top";
        }
      ];
      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = "Password...";
          shadow_passes = 2;
        }
      ];
    };
  };
}
