{ config, pkgs, lib, ... }:

{
  # mpd: music player daemon.
  # L'audio passa da PipeWire (output plugin nativo "pipewire", il pacchetto mpd
  # di nixpkgs è compilato con questo supporto di default).
  services.mpd = {
    enable = true;
    musicDirectory = config.home.homeDirectory + "/Musica";
    playlistDirectory = config.home.homeDirectory + "/.config/mpd/playlists";
    extraConfig = ''
      audio_output {
          type "pipewire"
          name "PipeWire"
      }
    '';
  };
}