_: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitEmptyPasswords = false;
      PermitTunnel = false;
      PermitRootLogin = "no";
      UseDns = false;
      KbdInteractiveAuthentication = false;
      AllowTcpForwarding = true;
      X11Forwarding = false;
      MaxAuthTries = 3;
      MaxSessions = 2;
      ClientAliveInterval = 300;
      ClientAliveCountMax = 0;
      AllowAgentForwarding = false;
      AllowStreamLocalForwarding = false;
      AllowUsers = [ ];
      TCPKeepAlive = false;
      LogLevel = "VERBOSE";
    };
    ports = [ 22023 ];
    hostKeys = [
      {
        type = "ed25519";
        path = "/etc/ssh/ssh_host_ed25519_key";
      }
    ];
  };
}
