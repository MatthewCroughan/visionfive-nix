{
  # Enable ssh on boot
  services.openssh.enable = true;
  networking.firewall.allowedTCPPorts = [ 19999 ];
  services.netdata.enable = true;
}
