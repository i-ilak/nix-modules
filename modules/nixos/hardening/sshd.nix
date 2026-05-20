{ config, lib, ... }:
{
  options.infra.profiles.sshd = {
    allowUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "root" ];
      description = "Users permitted to SSH in. Overrides hardening default.";
    };
    ports = lib.mkOption {
      type = lib.types.listOf lib.types.port;
      default = [ 22023 ];
      description = "SSH listen ports.";
    };
  };

  config = {
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
        AllowUsers = lib.mkForce config.infra.profiles.sshd.allowUsers;
        TCPKeepAlive = false;
        LogLevel = "VERBOSE";
      };
      inherit (config.infra.profiles.sshd) ports;
      hostKeys = [
        {
          type = "ed25519";
          path = "/etc/ssh/ssh_host_ed25519_key";
        }
      ];
    };
  };
}
