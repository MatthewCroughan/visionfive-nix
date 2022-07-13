{
  networking.firewall.allowedTCPPorts = [ 1883 ];
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
