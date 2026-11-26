{ config, ... }:
{
  # --- WireGuard: a private link from the laptop (quasar) to this host
  #
  # Quasar sits behind NAT and moves between networks, so pulsar cannot open a
  # connection to it. Quasar dials in to pulsar's public address instead and
  # keeps the tunnel alive; pulsar then reaches it at 10.77.0.2 (ssh, devos).
  # Pulsar has a public IP, so no coordination service (Tailscale) is needed.
  #
  #   pulsar  10.77.0.1  listens on udp/51820
  #   quasar  10.77.0.2  hosts/quasar/wireguard.nix, dials pulsar
  #
  # The private key lives in its own sops file, so adding it needed only the
  # public recipients of ../../.sops.yaml. Public keys are not secret.

  sops.secrets."wireguard/private_key" = {
    sopsFile = ./secrets/wireguard.yaml;
  };

  networking.wireguard.interfaces.wg0 = {
    ips = [ "10.77.0.1/24" ];
    listenPort = 51820;
    privateKeyFile = config.sops.secrets."wireguard/private_key".path;

    peers = [
      {
        # quasar
        publicKey = "j2RWIT0p6Z59ARS9f6wZYtWuTXY/i2wjBQIvDxKKMyE=";
        allowedIPs = [ "10.77.0.2/32" ];
      }
    ];
  };

  # Only the tunnel port itself. wg0 is deliberately NOT a trusted interface:
  # traffic from quasar still goes through nixos-fw like any other, so only
  # what is open globally (ssh) is reachable over the tunnel.
  networking.firewall.allowedUDPPorts = [ 51820 ];
}
