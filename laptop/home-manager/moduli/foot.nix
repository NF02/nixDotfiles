{ config, pkgs, lib, ... }:

{
  # Foot terminal emulator configuration
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "OpenDyslexicM Nerd Font Mono:size=8";
        pad = "5x0 center";
        dpi-aware = "yes";
        initial-window-size-pixels = "1200x720";
        term = "xterm-256color";
      };

      scrollback = {
        lines = 10000;
      };

      cursor = {
        style = "beam";
        blink = "yes";
        beam-thickness = 1.5;
      };

      mouse = {
        hide-when-typing = "yes";
      };

      url = {
        launch = "xdg-open \${url}";
      };

      bell = {
        urgent = "no";
        notify = "no";
        visual = "yes";
      };
    };
  };

  # Theme files for foot (managed by darkman for light/dark switching)
  xdg.configFile."foot/themes/dark.ini".text = ''
    [colors]
    alpha=0.95
    background=5d0c5a
    foreground=cdd6f4

    regular0=45475a
    regular1=f38ba8
    regular2=a6e3a1
    regular3=f9e2af
    regular4=89b4fa
    regular5=f5c2e7
    regular6=94e2d5
    regular7=bac2de

    bright0=585b70
    bright1=f38ba8
    bright2=a6e3a1
    bright3=f9e2af
    bright4=89b4fa
    bright5=f5c2e7
    bright6=94e2d5
    bright7=a6adc8
  '';

  xdg.configFile."foot/themes/light.ini".text = ''
    [colors]
    alpha=0.95
    background=fbf1c7
    foreground=4c4f69

    regular0=5c5f77
    regular1=d20f39
    regular2=40a02b
    regular3=df8e1d
    regular4=1e66f5
    regular5=ea76cb
    regular6=179299
    regular7=acb0be

    bright0=6c6f85
    bright1=d20f39
    bright2=40a02b
    bright3=df8e1d
    bright4=1e66f5
    bright5=ea76cb
    bright6=179299
    bright7=bcc0cc
  '';

  # Symlink current.ini -> dark.ini (default theme, updated by darkman)
  xdg.configFile."foot/themes/current.ini".source = 
    config.xdg.configFile."foot/themes/dark.ini".source;
}
