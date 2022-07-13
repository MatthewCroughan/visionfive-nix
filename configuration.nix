{
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
