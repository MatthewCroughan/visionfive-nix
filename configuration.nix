{ pkgs, config, lib, ... }:
{
  hardware.opengl.enable = true;
  programs.sway.enable = true;
  systemd.user.services.sway = {
    unitConfig = {
      Description = "Sway - Wayland window manager";
      Documentation = [ "man:sway(5)" ];
      BindsTo = [ "graphical-session.target" ];
      Wants = [ "graphical-session-pre.target" ];
      After = [ "graphical-session-pre.target" ];
    };
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.sway}/bin/sway";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
#  services.cage = {
#    enable = true;
#    user = "default";
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
