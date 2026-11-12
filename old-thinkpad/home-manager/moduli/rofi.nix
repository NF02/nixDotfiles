{ config, lib, pkgs, ... }:

let
  # Palette allineata a foot/alacritty: viola scuro per la modalità dark,
  # carta chiara per la modalità light. current.rasi è un symlink gestito
  # dallo script di darkman (moduli/darkman.nix).
  darkTheme = ''
    * {
        bg:            #5d0c5a;
        bg-alt:        #6e1a6b;
        fg:            #cdd6f4;
        fg-dim:        #9aa0b5;
        accent:        #89b4fa;
        accent-fg:     #1e1e2e;
        urgent:        #f38ba8;

        background-color: transparent;
        text-color:       @fg;
        border-color:     @accent;
        separatorcolor:   @bg-alt;
        spacing:          8;

        normal-background:            @bg;
        normal-foreground:            @fg;
        alternate-normal-background:  @bg-alt;
        alternate-normal-foreground:  @fg;
        selected-normal-background:   @accent;
        selected-normal-foreground:   @accent-fg;
        active-background:            @bg-alt;
        active-foreground:            @accent;
        selected-active-background:   @accent;
        selected-active-foreground:   @accent-fg;
        alternate-active-background:  @bg-alt;
        alternate-active-foreground:  @accent;
        urgent-background:            @bg;
        urgent-foreground:            @urgent;
        selected-urgent-background:   @urgent;
        selected-urgent-foreground:   @accent-fg;
        alternate-urgent-background:  @bg-alt;
        alternate-urgent-foreground:  @urgent;
    }

    window {
        background-color: @bg;
        border:           2px;
        border-color:     @accent;
        border-radius:    12px;
        padding:          12px;
        width:            40%;
    }

    mainbox {
        padding: 0;
        spacing: 8px;
    }

    inputbar {
        background-color: @bg-alt;
        text-color:       @fg;
        border-radius:    8px;
        padding:          8px 12px;
        spacing:          8px;
        children:         [ prompt, entry, case-indicator ];
    }

    prompt        { text-color: @accent; }
    entry         { text-color: @fg; }
    case-indicator { text-color: @fg-dim; }

    listview {
        lines:     10;
        spacing:   4px;
        border:    0;
        padding:   4px 0 0 0;
        scrollbar: false;
    }

    element {
        padding:       6px 10px;
        border-radius: 8px;
        spacing:       8px;
    }

    element-text {
        background-color: inherit;
        text-color:       inherit;
    }

    element-icon {
        size: 20px;
    }

    element.normal.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
    }
    element.selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    element.alternate.normal {
        background-color: @alternate-normal-background;
        text-color:       @alternate-normal-foreground;
    }
    element.normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
    }
    element.selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
    }
    element.normal.active {
        background-color: @active-background;
        text-color:       @active-foreground;
    }
    element.selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
    }

    message {
        border:       1px dash 0px 0px;
        border-color: @separatorcolor;
        padding:      4px 0 0 0;
    }

    textbox { text-color: @fg; }

    mode-switcher {
        border:       1px dash 0px 0px;
        border-color: @separatorcolor;
        padding:      4px 0 0 0;
    }

    button {
        padding:       4px 8px;
        border-radius: 6px;
        text-color:    @fg-dim;
    }

    button.selected {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }

    scrollbar {
        width:        4px;
        border:       0;
        handle-width: 8px;
        padding:      0;
    }
  '';

  lightTheme = ''
    * {
        bg:            #fbf1c7;
        bg-alt:        #f2e5bc;
        fg:            #4c4f69;
        fg-dim:        #8c8fa1;
        accent:        #1e66f5;
        accent-fg:     #fbf1c7;
        urgent:        #d20f39;

        background-color: transparent;
        text-color:       @fg;
        border-color:     @accent;
        separatorcolor:   @bg-alt;
        spacing:          8;

        normal-background:            @bg;
        normal-foreground:            @fg;
        alternate-normal-background:  @bg-alt;
        alternate-normal-foreground:  @fg;
        selected-normal-background:   @accent;
        selected-normal-foreground:   @accent-fg;
        active-background:            @bg-alt;
        active-foreground:            @accent;
        selected-active-background:   @accent;
        selected-active-foreground:   @accent-fg;
        alternate-active-background:  @bg-alt;
        alternate-active-foreground:  @accent;
        urgent-background:            @bg;
        urgent-foreground:            @urgent;
        selected-urgent-background:   @urgent;
        selected-urgent-foreground:   @accent-fg;
        alternate-urgent-background:  @bg-alt;
        alternate-urgent-foreground:  @urgent;
    }

    window {
        background-color: @bg;
        border:           2px;
        border-color:     @accent;
        border-radius:    12px;
        padding:          12px;
        width:            40%;
    }

    mainbox {
        padding: 0;
        spacing: 8px;
    }

    inputbar {
        background-color: @bg-alt;
        text-color:       @fg;
        border-radius:    8px;
        padding:          8px 12px;
        spacing:          8px;
        children:         [ prompt, entry, case-indicator ];
    }

    prompt        { text-color: @accent; }
    entry         { text-color: @fg; }
    case-indicator { text-color: @fg-dim; }

    listview {
        lines:     10;
        spacing:   4px;
        border:    0;
        padding:   4px 0 0 0;
        scrollbar: false;
    }

    element {
        padding:       6px 10px;
        border-radius: 8px;
        spacing:       8px;
    }

    element-text {
        background-color: inherit;
        text-color:       inherit;
    }

    element-icon {
        size: 20px;
    }

    element.normal.normal {
        background-color: @normal-background;
        text-color:       @normal-foreground;
    }
    element.selected.normal {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }
    element.alternate.normal {
        background-color: @alternate-normal-background;
        text-color:       @alternate-normal-foreground;
    }
    element.normal.urgent {
        background-color: @urgent-background;
        text-color:       @urgent-foreground;
    }
    element.selected.urgent {
        background-color: @selected-urgent-background;
        text-color:       @selected-urgent-foreground;
    }
    element.normal.active {
        background-color: @active-background;
        text-color:       @active-foreground;
    }
    element.selected.active {
        background-color: @selected-active-background;
        text-color:       @selected-active-foreground;
    }

    message {
        border:       1px dash 0px 0px;
        border-color: @separatorcolor;
        padding:      4px 0 0 0;
    }

    textbox { text-color: @fg; }

    mode-switcher {
        border:       1px dash 0px 0px;
        border-color: @separatorcolor;
        padding:      4px 0 0 0;
    }

    button {
        padding:       4px 8px;
        border-radius: 6px;
        text-color:    @fg-dim;
    }

    button.selected {
        background-color: @selected-normal-background;
        text-color:       @selected-normal-foreground;
    }

    scrollbar {
        width:        4px;
        border:       0;
        handle-width: 8px;
        padding:      0;
    }
  '';
in
{
  programs.rofi = {
    enable = true;

    # Il tema effettivo è scelto da darkman tramite questo symlink.
    theme = "${config.home.homeDirectory}/.config/rofi/themes/current.rasi";

    settings = {
      font = "OpenDyslexic Nerd Font 10";
      show-icons = true;
      icon-theme = "Adwaita";
      drun-display-format = "{name}";
      hover-select = true;
      sorting-method = "fzf";
    };
  };

  xdg.configFile = {
    "rofi/themes/dark.rasi".text = darkTheme;
    "rofi/themes/light.rasi".text = lightTheme;
  };
}
