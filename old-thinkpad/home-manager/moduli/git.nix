{ config, lib, pkgs, ... }:

{
  # Configurazione di Git di base
  home.packages = [ pkgs.git ];

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "<YOUR_NAME>";
        email = "<YOUR_EMAIL>";
      };
    };
  };
}