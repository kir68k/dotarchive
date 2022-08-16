{
  config,
  pkgs,
  lib,
  ...
}:

with lib; let
  cfg = config.ki.ssh;
in {
  options.ki.ssh = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable OpenSSH";
    };

    type = mkOption {
      type = types.enum [ "client" "server" ];
      default = "client";
      description = "Whether is an SSH client or server";
    };

    authorizedKeys = mkOption {
      type = with types; listOf str;
      description = "Authorized SSH keys";
    };

    initrdKeys = mkOption {
      type = with types; listOf str;
      description = "SSH key for initial ramdisk";
    };

    ports = mkOption {
      type = with types; listOf port;
      default = [ 1337 ];
      description = "SSH ports";
    };

    firewall = mkOption {
      type = types.bool;
      description = "Open firewall";
    };

    hostKeyAge = mkOption {
      type = types.path;
      description = "Age encrypted SSH host key file";
    };

    hostKeyPath = mkOption {
      type = types.path;
      default = "/etc/ssh/host_priv";
      description = "Path to decrypted SSH key";
    };
  };

  config = mkMerge [
    (mkIf (cfg.type == "client") {
      programs.ssh.startAgent = true;
    })
    (mkIf (cfg.type == "server" && cfg.firewall) {
      services.openssh.openFirewall = true;
    })
    {
      services.openssh = {
        enable = true;
        ports = cfg.ports;
        hostKeys = [];
        extraConfig = ''
          HostKey ${cfg.hostKeyPath}
        '';
      };

      # Term info for correct formatting of SSH term
      environment.systemPackages = with pkgs; [
        foot.terminfo
      ];

      #age.secrets.ssh_host_private_key = {
      #  file = cfg.hostKeyAge;
      #  path = cfg.hostKeyPath;
      #  mode = "600";
      #};

      users.users.root = {
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
      };
    }

    #(mkIf (config.ki.boot.type == "zfs") {
    #  boot.initrd = {
    #    network = {
    #      enable = true;
    #      ssh = {
    #        enable = true;
    #        port = 4444;
    #        hostKeys = [ "/etc/secrets/initrd/ssh_host_ed25519_key" ];
    #        authorizedKeys = cfg.initrdKeys;
    #      };
    #      postCommands = ''
    #        cat <<EOF > /root/.profile
    #        if pgrep -x "zfs" > /dev/null
    #        then
    #          zfs load-key -a
    #          killall zfs
    #        else
    #          echo "ZFS not running, maybe the pool is taking a long time to load?"
    #        fi
    #        EOF
    #      '';
    #    };
    #  };
    #})
  ];
}
