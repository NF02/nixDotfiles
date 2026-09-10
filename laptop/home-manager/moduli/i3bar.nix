{ config, pkgs, ... }:

{
  # Tema personalizzato conforme ai colori della barra di Sway
  home.file.".config/i3status-rust/themes/purple.toml".text = ''
    idle_bg = "#5D0C5A"
    idle_fg = "#FFFFFF"
    info_bg = "#5D0C5A"
    info_fg = "#E59FF4"
    good_bg = "#C38CE7"
    good_fg = "#222222"
    warning_bg = "#5F676A"
    warning_fg = "#FFFFFF"
    critical_bg = "#900000"
    critical_fg = "#FFFFFF"
    separator = "\ue0b2"
    separator_bg = "auto"
    separator_fg = "auto"
  '';

  programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "purple";
      icons = "awesome6";
      blocks = [
        {
          block = "cpu";
          interval = 1;
        }
        {
          block = "memory";
          format = " $icon $mem_used.eng(w:3,u:B,p:Mi)/$mem_total.eng(w:3,u:B,p:Mi) ($mem_used_percents.eng(w:2)) ";
        }
        {
          block = "net";
          device = "wlan0";
          format = " $icon  $ssid ($signal_strength) ";
        }
        {
          block = "sound";
        }
        {
          block = "battery";
          format = " $icon $percentage ";
          interval = 5;
        }
        {
          block = "time";
          interval = 60;
          format = " $icon $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };
}
