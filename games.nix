{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    luanti
  ];
}