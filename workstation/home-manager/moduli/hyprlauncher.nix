{ config, lib, pkgs, ... }:

{
  services.hyprlauncher = {
    enable = true;
    settings = {
      general = {
        grab_focus = true;
        show_desktop_entries = true;
      };

      cache = {
        enabled = true;
      };

      ui = {
        # Dimensioni e posizionamento in stile minimal
        window_size = "650 380";
      };

      finders = {
        desktop_icons = true;
        math_prefix = "=";
        unicode_prefix = ":";
      };
    };
  };

  # Materializza ~/.config/hypr/hyprtoolkit.conf come file reale (non symlink)
  # per permettere a darkman di cambiarlo a runtime come fa con waybar/style.css
  home.activation.materializeHyprtoolkitConf = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    if [ -L "$HOME/.config/hypr/hyprtoolkit.conf" ]; then
      rm -f "$HOME/.config/hypr/hyprtoolkit.conf"
    fi
    if [ ! -e "$HOME/.config/hypr/hyprtoolkit.conf" ]; then
      if [ -f "$HOME/.config/hypr/hyprtoolkit-dark.conf" ]; then
        cp -f "$HOME/.config/hypr/hyprtoolkit-dark.conf" "$HOME/.config/hypr/hyprtoolkit.conf"
      elif [ -f "$HOME/.config/hypr/hyprtoolkit-light.conf" ]; then
        cp -f "$HOME/.config/hypr/hyprtoolkit-light.conf" "$HOME/.config/hypr/hyprtoolkit.conf"
      fi
    fi
    chmod 644 "$HOME/.config/hypr/hyprtoolkit.conf" 2>/dev/null || true
  '';

  # Hyprlauncher segue il tema di hyprtoolkit - configurazione dark/light
  xdg.configFile."hypr/hyprtoolkit-dark.conf" = {
    force = true;
    text = ''
      font_family = OpenDyslexic Nerd Font
      font_size = 11

      background = 0xff2a0428
      base = 0xff3a0f38
      alternate_base = 0xff4a1d47
      button = 0xff4a1d47
      bright_text = 0xffe7c6ff
      text = 0xffffffff
      dim_text = 0xffb9a3c4
      accent = 0xffc38ce7
      accent_secondary = 0xffe7c6ff

      rounding = 8
    '';
  };

  xdg.configFile."hypr/hyprtoolkit-light.conf" = {
    force = true;
    text = ''
      font_family = OpenDyslexic Nerd Font
      font_size = 11

      background = 0xfffbf1c7
      base = 0xfff2e5bc
      alternate_base = 0xffebdbb2
      button = 0xffebdbb2
      bright_text = 0xff7a4b9a
      text = 0xff202020
      dim_text = 0xff7c6f64
      accent = 0xff7a4b9a
      accent_secondary = 0xff9c6bbe

      rounding = 8
    '';
  };
}

