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

  # Remote Login (Apple's sshd), keys only. Which keys may log in is not set
  # yet: no key is authorized until one is added deliberately.
  services.openssh = {
    enable = true;
    extraConfig = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
    '';
  };
}
