{ config, pkgs, ... }:

{
  # standby fix
  boot.kernelParams = [ "mem_sleep_default=deep" ];
  
  # bluetooth
  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot
  hardware.sensor.iio.enable = true;
  environment.systemPackages = [ pkgs.iio-sensor-proxy ]; 
}
