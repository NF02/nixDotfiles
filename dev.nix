{ config, pkgs, ... }:


{
	environment.systemPackages = with pkgs; [
		pkgs.eclipses.eclipse-java
		pkgs.eclipses.eclipse-jee
		pkgs.eclipses.eclipse-modeling
		#pkgs.gnucobol
		pkgs.libtool
		pkgs.gnumake
		pkgs.libgcc
		pkgs.cmake
		pkgs.gcc
		pkgs.automake
		pkgs.ninja
		pkgs.gfortran
		pkgs.octaveFull
		pkgs.scilab-bin
		pkgs.github-desktop
		pkgs.ntfs3g
	];
}
