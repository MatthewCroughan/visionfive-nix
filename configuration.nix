{
  imports = [
    ./examples/launchCageOnBoot.nix
  ];

#  networking = {
#    interfaces."wlan0".useDHCP = true;
#    wireless = {
#      interfaces = [ "wlan0" ];
#      enable = true;
#      networks = {
#        myWifiNetworkSSID.pskRaw = "29f4be0s82e33c18149cdcfc869f84ce6a8831fb492e35d759468f6103bf8a31"; # pskRaw is the result of running wpa_passphrase 'SSID' 'PASSWORD'
#        WIFI_SSID.psk = "WIFI_PASSWORD";
#      };
#    };
#  };

  networking.hostName = "visionfive-nix";

  # Enable ssh on boot
  services.openssh.enable = true;

  # Open port 19999 for Netdata
  networking.firewall.allowedTCPPorts = [ 19999 ];
  services.netdata.enable = true;

  # Enable Avahi mDNS, you should be able to reach http://visionfive-nix:19999
  # to reach netdata when booted
  services.avahi.enable = true;
}
