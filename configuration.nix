{ pkgs, config, lib, ... }:
{
  hardware.opengl.enable = true;
  programs.sway.enable = true;
  services.cage = {
    enable = true;
  };
#  services.xserver = {
#    enable = true;
#    displayManager.sx.enable = true;
#    desktopManager..enable = true;
#  };
  networking = {
    networkmanager.unmanaged = [ "wlan0" ];
    interfaces."wlan0".useDHCP = true;
    wireless = {
      interfaces = [ "wlan0" ];
      enable = true;
      networks = {
        ELANET-E6C0C16E.pskRaw = "29f4be0c82e38c18149cdcfc869084ce6a8831fb492e35d759468f6103bf8a31";
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 1883 19999 ];
  services.netdata.enable = true;
  services.mosquitto = {
    enable = true;
    settings.max_keepalive = 300;
    listeners = [
      {
        port = 1883;
        omitPasswordAuth = true;
        users = {};
        settings = {
          allow_anonymous = true;
        };
        acl = [ "topic readwrite #" ];
      }
    ];
  };
}
