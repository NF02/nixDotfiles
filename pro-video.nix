{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
    obs-studio
    obs-studio-plugins.obs-vaapi
    obs-studio-plugins.obs-teleport
    obs-studio-plugins.droidcam-obs
    obs-studio-plugins.waveform
    obs-studio-plugins.obs-pipewire-audio-capture
    shotcut
	];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      amdvlk
      amdenc
      pkgs.amf
      pkgs.amf-headers
      pkgs.libva-vdpau-driver
      pkgs.libva1
    ];
  };
}
