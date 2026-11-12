{ config, pkgs, lib, ... }:

{
  # Alacritty: terminale predefinito della sessione Sway.
  # Configurazione in stile "purple" coerente con Sway/foot.
  programs.alacritty = {
    enable = true;

    settings = {
      window = {
        padding = {
          x = 6;
          y = 6;
        };
        dynamic_padding = true;
        decorations = "None";
        opacity = 0.95;
      };

      scrolling = {
        history = 10000;
        multiplier = 3;
      };

      font = {
        normal = {
          family = "OpenDyslexicM Nerd Font Mono";
          style = "Regular";
        };
        size = 9.0;
      };

      cursor = {
        style = {
          shape = "Beam";
          blinking = "On";
        };
        blink_interval = 750;
        blink_timeout = 5;
        thickness = 0.15;
      };

      mouse.hide_when_typing = true;

      selection.save_to_clipboard = true;

      colors = {
        primary = {
          background = "#5d0c5a";
          foreground = "#cdd6f4";
          dim_foreground = "#7f849c";
          bright_foreground = "#cdd6f4";
        };
        cursor = {
          text = "#5d0c5a";
          cursor = "#f5e0dc";
        };
        vi_mode_cursor = {
          text = "#5d0c5a";
          cursor = "#b4befe";
        };
        selection = {
          text = "#5d0c5a";
          background = "#c38ce7";
        };
        normal = {
          black = "#45475a";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#bac2de";
        };
        bright = {
          black = "#585b70";
          red = "#f38ba8";
          green = "#a6e3a1";
          yellow = "#f9e2af";
          blue = "#89b4fa";
          magenta = "#f5c2e7";
          cyan = "#94e2d5";
          white = "#a6adc8";
        };
      };

      keyboard.bindings = [
        {
          key = "C";
          mods = "Control|Shift";
          action = "Copy";
        }
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
        {
          key = "=";
          mods = "Control";
          action = "IncreaseFontSize";
        }
        {
          key = "-";
          mods = "Control";
          action = "DecreaseFontSize";
        }
        {
          key = "0";
          mods = "Control";
          action = "ResetFontSize";
        }
      ];

      env = {
        TERM = "xterm-256color";
      };
    };
  };
}
