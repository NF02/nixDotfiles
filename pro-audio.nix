{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
		pkgs.vst2-sdk
		pkgs.lsp-plugins
		pkgs.lmms
		pkgs.vlc
		pkgs.carla
		pkgs.ladspaPlugins
		pkgs.vamp-plugin-sdk
		pkgs.ladspaPlugins
		pkgs.lv2
		pkgs.supercollider
		pkgs.supercolliderPlugins.sc3-plugins
	];
}