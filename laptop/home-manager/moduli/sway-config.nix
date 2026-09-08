{ config, pkgs, lib, ... }:

{
  # --- LOCKSCREEN: swaylock + swayidle (schermata di blocco al lock/idle) ---
  home.packages = with pkgs; [ swaylock swayidle ];

  wayland.windowManager.sway = {
    enable = true;
    config = {
      # --- VARIABLES & MODIFIER ---
      modifier = "Mod4"; # Assumiamo Mod4 ($mod) come Super/Logo
      terminal = "foot";
      menu = "rofi -show drun";

      fonts = {
        names = [ "OpenDyslexic Nerd Font" ];
        size = 10.0;
      };

      # --- INPUT: TOUCHPAD & KEYBOARD LAYOUT (keybord-layout.conf) ---
      input = {
        "type:touchpad" = {
          left_handed = "enabled";
          tap = "disabled";
          natural_scroll = "enabled";
          dwt = "enabled";
          accel_profile = "adaptive";
          pointer_accel = "-0.1";
        };
        "*" = {
          xkb_layout = "it";
        };
        "7847:2311:SEMITEK_USB-HID_Gaming_Keyboard" = {
          xkb_layout = "us";
          xkb_variant = "altgr-intl";
        };
      };

      # --- GAPS (gaps.conf) ---
      gaps = {
        smartGaps = true;
        inner = 5;
        outer = 5;
      };

      # --- WINDOW RULES (app.conf) ---
      window.commands = [
        # Thunderbird
        {
          command = "border none";
          criteria = { app_id = "thunderbird-default"; };
        }
        # Software
        {
          command = "border none";
          criteria = { app_id = "org.gnome.Software"; };
        }
        # Google Meet in Chromium
        {
          command = "floating enable";
          criteria = { app_id = "chromium"; title = "Meet"; };
        }
        # XDG Desktop Portals
        {
          command = "floating enable, border none";
          criteria = { app_id = "xdg-desktop-portal"; };
        }
        {
          command = "floating enable, border none";
          criteria = { app_id = "xdg-desktop-portal-gtk"; };
        }
        {
          command = "floating enable, border none";
          criteria = { app_id = "xdg-desktop-portal-kde"; };
        }
      ];

      # --- COLORS (colors.conf) ---
      colors = {
        focused = {
          border = "#C38CE7";
          background = "#5D0C5A";
          text = "#FFFFFF";
          indicator = "#E59FF4";
          childBorder = "#685877";
        };
        focusedInactive = {
          border = "#333333";
          background = "#5F676A";
          text = "#FFFFFF";
          indicator = "#484E50";
          childBorder = "#5F676A";
        };
        unfocused = {
          border = "#333333";
          background = "#222222";
          text = "#888888";
          indicator = "#292D2E";
          childBorder = "#222222";
        };
        urgent = {
          border = "#2F343A";
          background = "#900000";
          text = "#FFFFFF";
          indicator = "#900000";
          childBorder = "#900000";
        };
        placeholder = {
          border = "#000000";
          background = "#0C0C0C";
          text = "#FFFFFF";
          indicator = "#000000";
          childBorder = "#0C0C0C";
        };
        background = "#FFFFFF";
      };

      
      # --- BARS (bars.conf) ---
      bars = [
        # Barra predefinita (i3status-rust) - visibile in modalità laptop
        {
          id = "bar_default";
          position = "top";
          mode = "dock";
          fonts = {
            names = [ "OpenDyslexic Nerd Font" ];
            size = 10.0;
          };
          statusCommand = "i3status-rs config-default.toml";
          colors = {
            background = "#5D0C5A";
            statusline = "#FFFFFF";
            separator = "#666666";

            focusedWorkspace = {
              border = "#C38CE7";
              background = "#5D0C5A";
              text = "#FFFFFF";
            };
            activeWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#FFFFFF";
            };
            inactiveWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#888888";
            };
            urgentWorkspace = {
              border = "#2F343A";
              background = "#900000";
              text = "#FFFFFF";
            };
            bindingMode = {
              border = "#2F343A";
              background = "#900000";
              text = "#FFFFFF";
            };
          };
        }
        # Barra tablet (i3blocks) - inizialmente invisibile in modalità laptop
        {
          id = "bar_tablet";
          position = "top";
          mode = "invisible";
          fonts = {
            names = [ "OpenDyslexic Nerd Font" ];
            size = 10.0;
          };
          statusCommand = "i3status-rs config-default.toml";
          extraConfig = ''
            height 45
            workspace_min_width 60
          '';
          colors = {
            background = "#5D0c5a85";
            statusline = "#FFFFFF";
            separator = "#666666";

            focusedWorkspace = {
              border = "#C38CE7";
              background = "#5D0C5A";
              text = "#FFFFFF";
            };
            activeWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#FFFFFF";
            };
            inactiveWorkspace = {
              border = "#333333";
              background = "#222222";
              text = "#888888";
            };
            urgentWorkspace = {
              border = "#2F343A";
              background = "#900000";
              text = "#FFFFFF";
            };
            bindingMode = {
              border = "#2F343A";
              background = "#900000";
              text = "#FFFFFF";
            };
          };
        }
      ];
      
      # --- GESTURES (gestures.conf): not natively supported, added via extraConfig ---
      
      bindswitches = {
        "tablet:on" = { action = "exec toggle-tablet-mode"; };
        "tablet:off" = { action = "exec toggle-tablet-mode"; };
      };

      # --- KEYBINDINGS & MEDIA KEYS (keybind.conf, media.conf, clipboard.conf, gaps.conf, colors.conf) ---
      # NOTA: attributo semplice (non mkOptionDefault) per sostituire i default del
      # modulo: le keybindings sono complete e i workspace usano nomi romanici (I..X).
      keybindings = let
        mod = config.wayland.windowManager.sway.config.modifier;
        ws1 = "I";
        ws2 = "II";
        ws3 = "III";
        ws4 = "IV";
        ws5 = "V";
        ws6 = "VI";
        ws7 = "VII";
        ws8 = "VIII";
        ws9 = "IX";
        ws10 = "X";
      in {
        # Navigazione & Layout base
        "${mod}+Return" = "exec ${config.wayland.windowManager.sway.config.terminal}";
        "${mod}+Shift+q" = "kill";
        "${mod}+d" = "exec ${config.wayland.windowManager.sway.config.menu}";
        "${mod}+Mod1+Shift+c" = "reload";
        "${mod}+Shift+e" = "exec swaynag -t warning -m 'You pressed the exit shortcut. Do you really want to exit sway? This will end your Wayland session.' -B 'Yes, exit sway' 'swaymsg exit'";

        # Movimento e Focus (Vim keys)
        "${mod}+h" = "focus left";
        "${mod}+j" = "focus down";
        "${mod}+k" = "focus up";
        "${mod}+l" = "focus right";

        "${mod}+Shift+h" = "move left";
        "${mod}+Shift+j" = "move down";
        "${mod}+Shift+k" = "move up";
        "${mod}+Shift+l" = "move right";

        # Movimento Frecce
        "${mod}+Shift+Left" = "move left";
        "${mod}+Shift+Down" = "move down";
        "${mod}+Shift+Up" = "move up";
        "${mod}+Shift+Right" = "move right";

        # Switch Workspace Romani
        "${mod}+1" = "workspace ${ws1}";
        "${mod}+2" = "workspace ${ws2}";
        "${mod}+3" = "workspace ${ws3}";
        "${mod}+4" = "workspace ${ws4}";
        "${mod}+5" = "workspace ${ws5}";
        "${mod}+6" = "workspace ${ws6}";
        "${mod}+7" = "workspace ${ws7}";
        "${mod}+8" = "workspace ${ws8}";
        "${mod}+9" = "workspace ${ws9}";
        "${mod}+0" = "workspace ${ws10}";

        # Sposta Finestra nei Workspace Romani
        "${mod}+Shift+1" = "move container to workspace ${ws1}";
        "${mod}+Shift+2" = "move container to workspace ${ws2}";
        "${mod}+Shift+3" = "move container to workspace ${ws3}";
        "${mod}+Shift+4" = "move container to workspace ${ws4}";
        "${mod}+Shift+5" = "move container to workspace ${ws5}";
        "${mod}+Shift+6" = "move container to workspace ${ws6}";
        "${mod}+Shift+7" = "move container to workspace ${ws7}";
        "${mod}+Shift+8" = "move container to workspace ${ws8}";
        "${mod}+Shift+9" = "move container to workspace ${ws9}";
        "${mod}+Shift+0" = "move container to workspace ${ws10}";

        # Gestione Layout
        "${mod}+b" = "splith";
        "${mod}+v" = "splitv";
        "${mod}+s" = "layout stacking";
        "${mod}+w" = "layout tabbed";
        "${mod}+e" = "layout toggle split";
        "${mod}+f" = "fullscreen";
        "${mod}+Shift+space" = "floating toggle";
        "${mod}+space" = "focus mode_toggle";
        "${mod}+a" = "focus parent";

        # Scratchpad
        "${mod}+Shift+minus" = "move scratchpad";
        "${mod}+minus" = "scratchpad show";

        # Modalità Resize
        "${mod}+r" = "mode resize";

        # Blocco Schermo e Scorciatoie aggiuntive
        "Mod1+l" = "exec swaylock -f -i ~/Documenti/lockscreen.png";
        "Mod4+F1" = "exec emacsclient -c";
        # Clipboard (clipboard.conf)
        "${mod}+Shift+v" = "exec cliphist list | rofi -dmenu -p \"Clipboard\" | cliphist decode | wl-copy";
        "${mod}+Shift+x" = "exec cliphist list | rofi -dmenu -p \"Clipboard delete\" | cliphist delete";

        # Colors / Theme Toggle (colors.conf)
        "${mod}+t" = "exec darkman toggle";

        # Gaps / Dynamic Layout (gaps.conf)
        "${mod}+g" = "exec swaymsg smart_gaps off, gaps inner current set 5, gaps outer current set 100";
        "${mod}+Shift+g" = "exec swaymsg smart_gaps on, gaps inner current set 5, gaps outer current set 5";

        # General Shortcuts (keybind.conf)
        "${mod}+Print" = "exec wlsyshot";
        "${mod}+n" = "exec swaync-client -t";
        "${mod}+m" = "exec device-menu";
        "${mod}+u" = "exec emojimenu";
        "${mod}+F2" = "exec texmacs";
        "${mod}+p" = "exec openscad";

        # Media Keys (media.conf)
        "XF86AudioRaiseVolume" = "exec wpctl set-volume -l 1 @DEFAULT_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_SINK@ 5%-";
        "XF86AudioMute" = "exec wpctl set-mute @DEFAULT_SINK@ toggle";
        "XF86AudioMicMute" = "exec wpctl set-mute @DEFAULT_SOURCE@ toggle";

        "XF86MonBrightnessDown" = "exec brightnessctl set 5%-";
        "XF86MonBrightnessUp" = "exec brightnessctl set 5%+";

        "XF86AudioPlay" = "exec playerctl play-pause";
        "XF86AudioNext" = "exec playerctl next";
        "XF86AudioPrev" = "exec playerctl previous";

        "XF86Search" = "exec bemenu-run";
      };

      # --- STARTUP SERVICES & APPLETS (applet.conf, clipboard.conf) ---
      startup = [
        { command = "swaync"; }
        { command = "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway"; always = true; }
        { command = "waypaper --restore"; always = true; }
        { command = "wl-paste --type text --watch cliphist store"; }
        { command = "wl-paste --type image --watch cliphist store"; }
        # Lockscreen: blocca dopo 5 minuti, spegne i DPMS dopo 10, blocca anche prima del sleep
        {
          command = "swayidle -w timeout 300 'swaylock -f -i ~/Documenti/lockscreen.png' timeout 600 'swaymsg \"output * dpms off\"' resume 'swaymsg \"output * dpms on\"' before-sleep 'swaylock -f -i ~/Documenti/lockscreen.png'";
          always = true;
        }
      ];
    };

    extraConfig = ''
      bindgesture swipe:right workspace prev
      bindgesture swipe:left workspace next
    '';
  };
}
