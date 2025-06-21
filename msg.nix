{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
  	telegram-desktop
	  discord
    kdePackages.kmail-account-wizard
    kdePackages.akonadi-import-wizard
    kdePackages.accounts-qt
	  kdePackages.kmail
	  kdePackages.kmailtransport
	  kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.kio-gdrive
    kdePackages.tokodon
    kdePackages.syntax-highlighting
    kdePackages.kdeconnect-kde
  ];
}
