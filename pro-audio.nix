{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
		vst2-sdk
		lsp-plugins
		lmms
		vlc
		carla
    jamesdsp-pulse
    jamesdsp-pulse
		ladspaPlugins
		vamp-plugin-sdk
		ladspaPlugins
		lv2
		supercollider
		supercolliderPlugins.sc3-plugins
    musescore
    sonic-visualiser
    easyeffects
    fil-plugins
    ardour
	];
}
