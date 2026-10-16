{ config, pkgs, lib, ... }:

{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        output = "HDMI-A-2";
        layer = "top";
        position = "top";
        height = 36;

        modules-left = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "pulseaudio" "custom/media" "network" "tray" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
          on-scroll-up = "hyprctl dispatch 'hl.dsp.focus({workspace=\"e+1\"})' ";
          on-scroll-down = "hyprctl dispatch 'hl.dsp.focus({workspace=\"e-1\"})' ";
        };
        "hyprland/window" = {
          format = "{}";
          max-length = 60;
        };
        clock = {
          format = "{:%H:%M - %d/%m/%Y}";
          interval = 30;
        };
        cpu = {
          format = "{usage}% ";
          interval = 3;
        };
        memory = {
          format = "{used}GiB ";
          interval = 5;
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "muted ";
          format-icons = [ "" "" "" ];
          on-click = "pavucontrol";
        };
        network = {
          interface = "wlan0";
          interval = 5;
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ifname} Wired ";
          format-linked = "{ifname} (no IP) ";
          format-disconnected = "offline ⚠";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}";
          tooltip-format-wifi = "{essid} ({signalStrength}%) - {ipaddr}";
          tooltip-format-disconnected = "nessuna connessione (systemd-networkd)";
        };
        "custom/media" = {
          format = "{}";
          interval = 5;
          exec = "${pkgs.playerctl}/bin/playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || echo \"\"";
          on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
        };
        "tray" = {
          spacing = 8;
        };
      };

      secondary = {
        output = "DP-1";
        layer = "top";
        position = "top";
        height = 36;
        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };
        clock = {
          format = "{:%A %d %B %Y - %H:%M}";
          interval = 60;
        };
      };
    };

    style = null;
  };

  xdg.configFile."waybar/style-dark.css" = {
    force = true;
    text = ''
      * {
        font-family: "OpenDyslexic Nerd Font", "Font Awesome 7 Free Solid", "Font Awesome 7 Free", sans-serif;
        font-size: 11px;
      }
      window#waybar {
        background-color: #5D0C5A;
        color: #FFFFFF;
      }
      #workspaces button {
        color: #888888;
        background-color: #222222;
        border: 1px solid #333333;
      }
      #workspaces button.active {
        color: #FFFFFF;
        background-color: #5D0C5A;
        border-color: #C38CE7;
      }
      #workspaces button.urgent {
        color: #FFFFFF;
        background-color: #900000;
      }
      #clock, #pulseaudio, #network, #custom-media, #window, #cpu, #memory, #tray {
        color: #FFFFFF;
        padding: 0 10px;
      }
    '';
  };

  xdg.configFile."waybar/style-light.css" = {
    force = true;
    text = ''
      * {
        font-family: "OpenDyslexic Nerd Font", "Font Awesome 7 Free Solid", "Font Awesome 7 Free", sans-serif;
        font-size: 11px;
      }
      window#waybar {
        background-color: #fbf1c7;
        color: #202020;
      }
      #workspaces button {
        color: #202020;
        background-color: #f2e5bc;
        border: 1px solid #d5c4a1;
      }
      #workspaces button.active {
        color: #202020;
        background-color: #ebdbb2;
        border-color: #7A4B9A;
      }
      #workspaces button.urgent {
        color: #FFFFFF;
        background-color: #900000;
      }
      #clock, #pulseaudio, #network, #custom-media, #window, #cpu, #memory, #tray {
        color: #202020;
        padding: 0 10px;
      }
    '';
  };

  home.packages = with pkgs; [
    font-awesome
    nerd-fonts.open-dyslexic
    playerctl
    pavucontrol
  ];
}
