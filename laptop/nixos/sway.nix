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
    pcmanfm
    udisks
    i3status-rust
    playerctl
    swaybg
    libnotify
    swaynotificationcenter
    waypaper
    wl-clipboard
    polkit_gnome
  ];
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
  # sensori di rotazione e giroscopio
  hardware.sensor.iio.enable = true;
}
