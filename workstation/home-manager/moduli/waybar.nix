{ config, pkgs, lib, ... }:

let
  # Hyprland 0.55+ (config Lua) ha rimosso i dispatcher legacy che Waybar 0.15
  # usa per i suoi moduli nativi: i click sui workspace non funzionano piu'.
  # Usiamo quindi moduli custom cliccabili, alimentati da questo script.
  hyprWorkspaces = pkgs.writeShellApplication {
    name = "waybar-hypr-workspaces";
    runtimeInputs = with pkgs; [
      hyprland
      jq
    ];
    text = builtins.readFile ../scripts/waybar-hypr-workspaces.sh;
  };

  wsNumbers = lib.range 1 9;
  wsModuleNames = map (n: "custom/ws${toString n}") wsNumbers;
  # Applica un suffisso (es. ":hover" o ".active") a *ogni* selettore:
  # concatenarlo alla lista creerebbe "a, b, c.active" e marcherebbe solo l'ultimo.
  wsCss = suffix: lib.concatMapStringsSep ", " (n: "#custom-ws${toString n}${suffix}") wsNumbers;

  wsModules = lib.listToAttrs (map (n: {
    name = "custom/ws${toString n}";
    value = {
      exec = "${hyprWorkspaces}/bin/waybar-hypr-workspaces status ${toString n}";
      format = "{}";
      return-type = "json";
      signal = 8;
      escape = true;
      tooltip = true;
      on-click = "${hyprWorkspaces}/bin/waybar-hypr-workspaces focus ${toString n}";
      on-click-right = "${hyprWorkspaces}/bin/waybar-hypr-workspaces move ${toString n}";
      on-scroll-up = "${hyprWorkspaces}/bin/waybar-hypr-workspaces rel 1";
      on-scroll-down = "${hyprWorkspaces}/bin/waybar-hypr-workspaces rel -1";
    };
  }) wsNumbers) // {
    "custom/secret" = {
      exec = "${hyprWorkspaces}/bin/waybar-hypr-workspaces secret-status";
      format = "{}";
      return-type = "json";
      signal = 8;
      escape = true;
      tooltip = true;
      on-click = "${hyprWorkspaces}/bin/waybar-hypr-workspaces secret-toggle";
    };
  };

  wsGroup = {
    orientation = "horizontal";
    modules = wsModuleNames ++ [ "custom/secret" ];
  };
in
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
        spacing = 8;

        modules-left = [ "group/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right = [ "custom/media" "pulseaudio" "cpu" "memory" "network" "tray" ];

        "group/workspaces" = wsGroup;
        "hyprland/window" = {
          format = "{}";
          max-length = 60;
          separate-outputs = true;
        };
        clock = {
          format = "{:%H:%M · %d/%m/%Y}";
          tooltip-format = "<tt><big>{calendar}</big></tt>";
          interval = 30;
          calendar = {
            mode = "month";
            weeks-pos = "left";
            on-scroll = 1;
            format = {
              months = "<span color='#C38CE7'><b>{}</b></span>";
              days = "{}";
              weekdays = "<span color='#C38CE7'><b>{}</b></span>";
              weeks = "<span color='#888888'><b>W{}</b></span>";
              today = "<span color='#FFFFFF'><b><u>{}</u></b></span>";
            };
          };
        };
        cpu = {
          format = "{usage}% ";
          interval = 3;
          tooltip = true;
          tooltip-format = "CPU: {usage}%\nFrequenza media: {avg_frequency} GHz";
        };
        memory = {
          format = "{used:0.1f} GiB ";
          interval = 5;
          tooltip = true;
          tooltip-format = "RAM: {used:0.1f} / {total:0.1f} GiB ({percentage}%)\nSwap: {swapUsed:0.1f} / {swapTotal:0.1f} GiB";
        };
        pulseaudio = {
          format = "{volume}% {icon}";
          format-muted = "muto ";
          format-icons = [ "" "" "" ];
          on-click = "pavucontrol";
          on-click-right = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          tooltip = true;
          tooltip-format = "{desc}\nVolume: {volume}%";
        };
        network = {
          interval = 5;
          format = "{ifname}";
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "LAN ";
          format-linked = "collegato ";
          format-disconnected = "offline ⚠";
          tooltip = true;
          tooltip-format = "{ifname}: {ipaddr}/{cidr}\n↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}";
          tooltip-format-wifi = "{essid} ({signalStrength}%)\n{ipaddr}/{cidr}\n↓ {bandwidthDownBytes} ↑ {bandwidthUpBytes}";
          tooltip-format-disconnected = "nessuna connessione (systemd-networkd)";
        };
        "custom/media" = {
          format = "♪ {}";
          interval = 5;
          max-length = 45;
          escape = true;
          exec = "${pkgs.playerctl}/bin/playerctl metadata --format '{{title}} - {{artist}}' 2>/dev/null || echo \"\"";
          on-click = "${pkgs.playerctl}/bin/playerctl play-pause";
          on-click-right = "${pkgs.playerctl}/bin/playerctl next";
          on-scroll-up = "${pkgs.playerctl}/bin/playerctl volume 0.05+";
          on-scroll-down = "${pkgs.playerctl}/bin/playerctl volume 0.05-";
        };
        "tray" = {
          spacing = 10;
        };
      } // wsModules;

      secondary = {
        output = "DP-1";
        layer = "top";
        position = "top";
        height = 36;
        modules-left = [ "group/workspaces" ];
        modules-center = [ "clock" ];
        modules-right = [ ];

        "group/workspaces" = wsGroup;
        clock = {
          format = "{:%A %d %B · %H:%M}";
          interval = 60;
          tooltip-format = "<tt><big>{calendar}</big></tt>";
          calendar = {
            mode = "month";
            weeks-pos = "left";
          };
        };
      } // wsModules;
    };

    style = null;
  };

  xdg.configFile."waybar/style-dark.css" = {
    force = true;
    text = ''
      * {
        font-family: "OpenDyslexic Nerd Font", "Font Awesome 7 Free Solid", "Font Awesome 7 Free", sans-serif;
        font-size: 11px;
        min-height: 0;
      }
      window#waybar {
        background-color: #2A0428;
        color: #FFFFFF;
        border-bottom: 1px solid #4A1D47;
      }
      tooltip {
        background-color: #2A0428;
        border: 1px solid #C38CE7;
        border-radius: 8px;
      }
      tooltip label {
        color: #F3E4FB;
        padding: 4px;
      }
      .modules-left, .modules-center, .modules-right {
        padding: 0 8px;
      }
      #workspaces {
        margin: 4px 0;
      }
      ${wsCss ""}, #custom-secret {
        padding: 0 9px;
        margin: 0 2px;
        min-width: 20px;
        color: #B9A3C4;
        background-color: rgba(255, 255, 255, 0.05);
        border: 1px solid transparent;
        border-radius: 6px;
        transition: all 150ms ease-in-out;
      }
      ${wsCss ":hover"}, #custom-secret:hover {
        color: #FFFFFF;
        background-color: rgba(195, 140, 231, 0.18);
      }
      ${wsCss ".occupied"} {
        color: #F3E4FB;
      }
      ${wsCss ".active"} {
        color: #2A0428;
        background-color: #C38CE7;
        border-color: #E7C6FF;
        font-weight: bold;
      }
      ${wsCss ".active.focused"} {
        border-color: #FFFFFF;
        box-shadow: inset 0 0 0 1px #FFFFFF;
      }
      ${wsCss ".empty"} {
        color: #8F7A96;
        background-color: rgba(255, 255, 255, 0.03);
      }
      #custom-secret {
        color: #E7C6FF;
        font-size: 13px;
      }
      #custom-secret.active {
        color: #2A0428;
        background-color: #E7C6FF;
        border-color: #FFFFFF;
      }
      #custom-secret.empty {
        color: #8F7A96;
      }
      #window {
        color: #E4D2F0;
        font-style: italic;
        padding: 0 10px;
      }
      #clock {
        margin: 4px 0;
        padding: 0 12px;
        color: #FFFFFF;
        font-weight: bold;
        letter-spacing: 0.3px;
        background-color: rgba(195, 140, 231, 0.12);
        border: 1px solid rgba(195, 140, 231, 0.25);
        border-radius: 6px;
      }
      #custom-media, #pulseaudio, #cpu, #memory, #network, #tray {
        margin: 4px 0;
        padding: 0 10px;
        color: #FFFFFF;
        background-color: rgba(255, 255, 255, 0.05);
        border-radius: 6px;
      }
      #custom-media {
        color: #E7C6FF;
      }
      #pulseaudio.muted {
        color: #FF9E9E;
      }
      #cpu.warning, #memory.warning {
        color: #FFD27F;
      }
      #cpu.critical, #memory.critical {
        color: #FF8A8A;
      }
      #network.disconnected {
        color: #FF9E9E;
      }
      #tray {
        padding: 0 8px;
        margin-right: 6px;
      }
    '';
  };

  xdg.configFile."waybar/style-light.css" = {
    force = true;
    text = ''
      * {
        font-family: "OpenDyslexic Nerd Font", "Font Awesome 7 Free Solid", "Font Awesome 7 Free", sans-serif;
        font-size: 11px;
        min-height: 0;
      }
      window#waybar {
        background-color: #FBF1C7;
        color: #202020;
        border-bottom: 1px solid #D5C4A1;
      }
      tooltip {
        background-color: #FBF1C7;
        border: 1px solid #7A4B9A;
        border-radius: 8px;
      }
      tooltip label {
        color: #202020;
        padding: 4px;
      }
      .modules-left, .modules-center, .modules-right {
        padding: 0 8px;
      }
      #workspaces {
        margin: 4px 0;
      }
      ${wsCss ""}, #custom-secret {
        padding: 0 9px;
        margin: 0 2px;
        min-width: 20px;
        color: #7C6F64;
        background-color: rgba(0, 0, 0, 0.04);
        border: 1px solid transparent;
        border-radius: 6px;
        transition: all 150ms ease-in-out;
      }
      ${wsCss ":hover"}, #custom-secret:hover {
        color: #202020;
        background-color: rgba(122, 75, 154, 0.14);
      }
      ${wsCss ".occupied"} {
        color: #202020;
      }
      ${wsCss ".active"} {
        color: #FFFFFF;
        background-color: #7A4B9A;
        border-color: #9C6BBE;
        font-weight: bold;
      }
      ${wsCss ".active.focused"} {
        border-color: #202020;
        box-shadow: inset 0 0 0 1px #202020;
      }
      ${wsCss ".empty"} {
        color: #9A8D84;
        background-color: rgba(0, 0, 0, 0.03);
      }
      #custom-secret {
        color: #7A4B9A;
        font-size: 13px;
      }
      #custom-secret.active {
        color: #FFFFFF;
        background-color: #7A4B9A;
        border-color: #9C6BBE;
      }
      #custom-secret.empty {
        color: #9A8D84;
      }
      #window {
        color: #5C4B51;
        font-style: italic;
        padding: 0 10px;
      }
      #clock {
        margin: 4px 0;
        padding: 0 12px;
        color: #202020;
        font-weight: bold;
        letter-spacing: 0.3px;
        background-color: rgba(122, 75, 154, 0.10);
        border: 1px solid rgba(122, 75, 154, 0.28);
        border-radius: 6px;
      }
      #custom-media, #pulseaudio, #cpu, #memory, #network, #tray {
        margin: 4px 0;
        padding: 0 10px;
        color: #202020;
        background-color: rgba(0, 0, 0, 0.04);
        border-radius: 6px;
      }
      #custom-media {
        color: #7A4B9A;
      }
      #pulseaudio.muted {
        color: #B3261E;
      }
      #cpu.warning, #memory.warning {
        color: #B57614;
      }
      #cpu.critical, #memory.critical {
        color: #B3261E;
      }
      #network.disconnected {
        color: #B3261E;
      }
      #tray {
        padding: 0 8px;
        margin-right: 6px;
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
