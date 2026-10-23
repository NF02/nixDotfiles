{ config, lib, pkgs, ... }:

let
  # Generazione automatica dei binding per i workspace 1..9
  # Sintassi Lua 0.56: focus per cambiare workspace, window.move per spostare finestra
  workspaceBinds = (map (i: {
    _args = [
      (lib.generators.mkLuaInline ''mod .. " + ${toString i}"'')
      (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = ${toString i} })'')
    ];
  }) (lib.range 1 9))
  ++ (map (i: {
    _args = [
      (lib.generators.mkLuaInline ''mod .. " + SHIFT + ${toString i}"'')
      (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = ${toString i} })'')
    ];
  }) (lib.range 1 9));
in
{
  
  # Wallpaper: hyprpaper (il cambio automatico light/dark e' gestito da darkman,
  # vedi darkman.nix).
  services.hyprpaper = {
    enable = true;
    settings = {
      splash = true;
      ipc = "on";
      wallpaper = [
        {
          monitor = "HDMI-A-2";
          path = "/home/nick/.cache/bg";
        }
        {
          monitor = "DP-1";
          path = "/home/nick/.cache/bg";
        }
      ];
    };
  };

  # Materializza ~/.config/waybar/style.css come file reale (non symlink) per
  # permettere a darkman di cambiarlo a runtime (copia style-dark/light).
  home.activation.materializeWaybarStyle = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -L "$HOME/.config/waybar/style.css" ]; then
      rm -f "$HOME/.config/waybar/style.css"
    fi
    if [ ! -e "$HOME/.config/waybar/style.css" ]; then
      cp -f "$HOME/.config/waybar/style-dark.css" "$HOME/.config/waybar/style.css"
    fi
    chmod 644 "$HOME/.config/waybar/style.css" 2>/dev/null || true
  '';

  # Waybar viene lanciato da systemd, ma il suo PATH potrebbe non contenere hyprctl.
  # Aggiunge il PATH per permettere al modulo hyprland/workspaces di spostarsi tra desktop.
  systemd.user.services.waybar = {
    Service = {
      Environment = "PATH=/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin:/home/nick/.nix-profile/bin:/nix/profile/bin";
    };
  };
  services.hyprpolkitagent.enable = true;  services.hyprsunset.enable = true;
  programs.hyprshot.enable = true;

  home.packages = with pkgs; [
    hyprlauncher
    playerctl
    cliphist
    wl-clipboard    # Font usati dalla barra (stessi di base.nix/ghostty/foot):
    # garantiscono che general.font-sans/font-mono risolvano sempre,
    # anche se emacs-config.nix (che porta nerd-fonts.open-dyslexic) e' disabilitato.
    nerd-fonts.open-dyslexic
    font-awesome
    # Tool usati dal modulo custom-systemd-net (iwctl + networkctl):
    iwd
    systemd
  ];

  # --------------------------------------------------
  # 2. Configurazione di Hyprland (Sintassi Lua Nativa)
  # --------------------------------------------------
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      mod = {
        _var = "SUPER";
      };

      # --- Configurazione Monitor (16:9 Sinistra | 5:4 Destra) ---
      monitor = [
        # Schermo 16:9 a Sinistra (HDMI-A-2)
        {
          _args = [
            {
              output = "HDMI-A-2";
              mode = "1920x1080@60";
              position = "0x0";
              scale = 1;
            }
          ];
        }
        # Schermo 5:4 a Destra (DP-1)
        {
          _args = [
            {
              output = "DP-1";
              mode = "1280x1024@75.03";
              position = "1920x0";
              scale = 1;
            }
          ];
        }
      ];

      config = {
        general = {
          gaps_in = 3;
          gaps_out = 10;
          border_size = 2;
        };

        decoration = {
          rounding = 5;
        };

        # --- Configurazione Tastiera (US AltGr International) ---
        input = {
          kb_layout = "us";
          kb_variant = "altgr-intl";
        };

        misc = {
          force_default_wallpaper = 0;
          disable_hyprland_logo = true;
        };
      };
      bind = [
        # --- Gestione Finestre e Sessione (Stile DWM) ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + Q"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.close()'')
            { locked = true; }
          ];
        }
        # Floating drag with Super + left mouse button
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse:272"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.drag()'')
            { mouse = true; }
          ];
        }
        # Resize with Super + right mouse button
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + mouse:273"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.resize()'')
            { mouse = true; }
          ];
        }        # Toggle floating with Super + Space
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SPACE"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
          ];
        }        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + E"'')
            (lib.generators.mkLuaInline ''hl.dsp.exit()'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + RETURN"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("ghostty")'')
          ];
        }
        # DWM zoom: MOD+RETURN scambia finestra corrente con la successiva (master/stack)
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + RETURN"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.swap({ next = true })'')
          ];
        }
        # Fullscreen toggle
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + F"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.fullscreen()'')
          ];
        }

        # Modalita' tabbed (gruppi)
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + W"'')
            (lib.generators.mkLuaInline ''hl.dsp.group.toggle()'')
          ];
        }
        # Navigazione tab (gruppi)
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + TAB"'')
            (lib.generators.mkLuaInline ''hl.dsp.group.next()'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + TAB"'')
            (lib.generators.mkLuaInline ''hl.dsp.group.prev()'')
          ];
        }        # Emacsclient
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + F1"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("emacsclient -c")'')
          ];
        }
        
        # --- Menu Launcher & Utility ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + P"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprlauncher")'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + T"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("darkman toggle")'')
          ];
        }
        # Scegli wallpaper con yazi: monitor + tema (dark/light), salvato per tema
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + ALT + W"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("ghostty -e wallpaper-picker")'')
          ];
        }

        # --- Secret workspace (special:secret) ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + S"'')
            (lib.generators.mkLuaInline ''hl.dsp.workspace.toggle_special("secret")'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + CTRL + S"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "special:secret", follow = false })'')
          ];
        }

        # Snipping tool: menu con hyprlauncher + catture con hyprshot
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + S"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("snipping")'')
          ];
        }

        # Pseudo-tile: di default su mod+P (Hyprland), ma mod+P e' gia' hyprlauncher
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + ALT + P"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.pseudo()'')
          ];
        }
        
        # --- Focus direzionale stile Vim (H/J/K/L) ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + H"'')
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "left" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + J"'')
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "down" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + K"'')
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "up" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + L"'')
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "right" })'')
          ];
        }

        # --- Sposta finestra stile Vim (MOD+SHIFT+H/J/K/L) ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + H"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "left" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + J"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "down" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + K"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "up" })'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + L"'')
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "right" })'')
          ];
        }

        # --- Clipboard (cliphist + hyprlauncher) ---
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + V"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("cliphist list | hyprlauncher --dmenu | cliphist decode | wl-copy")'')
          ];
        }
        {
          _args = [
            (lib.generators.mkLuaInline ''mod .. " + SHIFT + X"'')
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("cliphist list | hyprlauncher --dmenu | cliphist delete")'')
          ];
        }

        # --- Controlli Multimediali e Audio ---
        {          _args = [
                     "XF86AudioRaiseVolume"
                     (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+")'')
                   ];
        }
        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
          ];
        }
        {
          _args = [
            "XF86AudioMute"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
          ];
        }

        # --- Screenshot (hyprshot) ---
        {
          _args = [
            "Print"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m region -o /home/nick/Immagini/screenshot")'')
          ];
        }
        {
          _args = [
            "SHIFT + Print"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m window -o /home/nick/Immagini/screenshot")'')
          ];
        }

        # --- Controlli Player (playerctl) ---
        {
          _args = [
            "XF86AudioPlay"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
            { locked = true; }
          ];
        }
        {
          _args = [
            "XF86AudioPause"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
            { locked = true; }
          ];
        }
        {
          _args = [
            "XF86AudioNext"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'')
            { locked = true; }
          ];
        }
        {
          _args = [
            "XF86AudioPrev"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'')
            { locked = true; }
          ];
        }
        {
          _args = [
            "XF86AudioStop"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl stop")'')
            { locked = true; }
          ];
        }
        # --- Controllo Luminosità ---
        {
          _args = [
            "XF86MonBrightnessUp"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%+")'')
          ];
        }
        {
          _args = [
            "XF86MonBrightnessDown"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl set 5%-")'')
          ];
        }

        # --- Submap per Ridimensionamento ---
        {
          _args = [
            "ALT + R"
            (lib.generators.mkLuaInline ''hl.dsp.submap("resize")'')
          ];
        }
      ] ++ workspaceBinds;

      define_submap = {
        _args = [
          "resize"
          (lib.generators.mkLuaInline ''
            function()
              hl.bind("right", hl.dsp.window.resize({ x = 10, y = 0, relative = true }), { repeating = true })
              hl.bind("left", hl.dsp.window.resize({ x = -10, y = 0, relative = true }), { repeating = true })
              hl.bind("escape", hl.dsp.submap("reset"))
            end
          '')
        ];
      };

      window_rule = {
        match = { class = "ghostty"; };
        border_size = 2;
      };

      workspace_rule = [
        {
          workspace = "w[tv1]";
          gaps_out = 0;
          gaps_in = 0;
        }
        {
          workspace = "f[1]";
          gaps_out = 0;
          gaps_in = 0;
        }
      ];
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("swaync")
              hl.exec_cmd("wl-paste --type text --watch cliphist store")
              hl.exec_cmd("wl-paste --type image --watch cliphist store")
            end
          '')
        ];
      };
    };
  };
}
