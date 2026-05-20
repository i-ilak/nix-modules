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
    permitRootLogin = lib.mkOption {
      type = lib.types.enum [
        "yes"
        "without-password"
        "prohibit-password"
        "forced-commands-only"
        "no"
      ];
      default = "no";
      description = "Value for sshd_config PermitRootLogin. Default 'no' is the hardened baseline; consumers needing key-based root login set 'prohibit-password'.";
    };
  };

  config = {
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitEmptyPasswords = false;
        PermitTunnel = false;
        PermitRootLogin = config.infra.profiles.sshd.permitRootLogin;
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
