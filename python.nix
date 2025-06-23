{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    python313Packages.pypdf2
    python313Packages.pdf2docx
  ];
}
