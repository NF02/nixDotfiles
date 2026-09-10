{ config, pkgs, ... }:

{
  services.displayManager.gdm.settings = {
    greeter = {
      IncludeAll = true;
    };
  };
  
	environment.systemPackages = with pkgs; [
   	rewaita
    gnome-tweaks
    telegram-desktop
    discord
    intel-media-driver
    intel-ocl
    intel-vaapi-driver
    gnomeExtensions.paperwm
    gnomeExtensions.ddterm
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.night-theme-switcher
    gnomeExtensions.dash-to-dock
    gnomeExtensions.rectangle
    gsettings-desktop-schemas
    glib
    qgnomeplatform
    qgnomeplatform-qt6
	];

  
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
    config.common.default = "*";
  };
  
  qt.platformTheme = {
    qt.platformTheme = "gnome";
  };
}
