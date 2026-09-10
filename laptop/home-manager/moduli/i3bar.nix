{ config, pkgs, ... }:

{
programs.i3status-rust = {
    enable = true;
    bars.default = {
      theme = "gruvbox-dark";
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
          block = "time";
          interval = 60;
          format = " $icon $timestamp.datetime(f:'%a %d/%m %R') ";
        }
      ];
    };
  };
}
