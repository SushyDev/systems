{ ... }:
{
  # --- WireGuard: dial pulsar, so pulsar can reach this laptop
  #
  # This laptop is behind NAT and changes networks; it keeps a tunnel open to
  # pulsar's public address, and pulsar reaches it at 10.77.0.2.
  # The other end is pulsar's wireguard.nix (10.77.0.1, udp/51820).
  #
  # The private key was generated on this machine and never left it. It is
  # not in this (public) repository.
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.77.0.2/24" ];
    privateKeyFile = "/Users/sushy/.config/wireguard/wg0.key";

    peers = [
      {
        # pulsar
        publicKey = "cQyATvm3xlN93APsEP1JF7AqHuOEXdaPbYi3cVyr0Gg=";
        endpoint = "78.46.96.138:51820";
        # Only the tunnel subnet: the laptop's normal traffic does not go via pulsar.
        allowedIPs = [ "10.77.0.0/24" ];
        # Keeps the NAT mapping open, so pulsar can reach in at any time.
        persistentKeepalive = 25;
      }
    ];
  };

  # Remote Login (Apple's sshd), keys only.
  #
  # Pulsar logs in with its own key (~/.ssh/quasar_ed25519 there), accepted only
  # from its tunnel address, so the key is useless anywhere but over wg0.
  users.users.sushy.openssh.authorizedKeys.keys = [
    ''from="10.77.0.1" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgZJSGwIJXpRscME0+N16j62QxYE5HgHyatnvjfJWdi pulsar to quasar over WireGuard''
  ];

  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };
}
