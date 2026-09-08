{ config, pkgs, ... }:

{
  services.displayManager.gdm.settings = {
    greeter = {
      IncludeAll = true;
    };
  };
  
	environment.systemPackages = with pkgs; [
   	rewaita
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
    gsettings-desktop-schemas
    glib
    qgnomeplatform
    qgnomeplatform-qt6
	];
  nixpkgs.overlays = [
    (self: super: {
      texstudio = super.texstudio.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.wrapGAppsHook3 ];
        buildInputs = (oldAttrs.buildInputs or []) ++ [ super.gsettings-desktop-schemas super.gtk3 ];
      });
    })
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
