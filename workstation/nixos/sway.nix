{ config, pkgs, ... }:

{
  programs.sway.enable = true;
  programs.sway.xwayland.enable = true;
  environment.systemPackages = with pkgs; [
    rofi
    rofi-bluetooth
    rofi-power-menu
    rofi-emoji
    wdisplays
    swayr
    swayimg
    pcmanfm
    mpv
    mpd
    ncmpcpp
    udisks
    i3status-rust
    playerctl
    swaybg
    libnotify
    swaynotificationcenter
    waypaper
    wl-clipboard
    cliphist
    hyprpolkitagent
  ];
  services.udisks2.enable = true;
  services.udisks2.mountOnMedia = true;

  environment.shells = with pkgs; [ nushell ];
  # power-manager
  services.upower.enable = true;
  # audio
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    GDK_BACKEND = "wayland,x11";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    config.common.default = "*";
  };
  
}
