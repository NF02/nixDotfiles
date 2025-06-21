{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    emacs-pgtk
    emacsPackages.vterm
    
  ];
}
