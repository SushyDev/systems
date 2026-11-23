{ ... }:
{
  # --- Networking
  networking.hostName = "pulsar";

  networking.firewall = {
    enable = true;

    # Only SSH is reachable from the public internet.
    #
    # 6443 (kube-apiserver) is deliberately NOT listed here. It is reached via
    # the trustedInterfaces declared in ./kubernetes.nix (mynet, cni0,
    # flannel.1) and via loopback. Listing it globally exposed the control
    # plane to the internet on 78.46.96.138.
    #
    # The Minecraft/Hytale ports (25567, 8100/tcp, 5520/udp) are NOT listed
    # either: they are Docker-published, so they arrive via DNAT and traverse
    # FORWARD, never INPUT. Docker's own DOCKER chain accepts them.
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];

    # NOTE: the previous version of this file hand-rolled an entire INPUT
    # policy in extraCommands and terminated it with `-A INPUT -j DROP`.
    # Because NixOS appends its own `-A INPUT -j nixos-fw` afterwards, that
    # DROP made the whole nixos-fw chain unreachable -- so allowedTCPPorts,
    # allowedUDPPorts and trustedInterfaces were silently dead config.
    # The hand-rolled chain is gone; nixos-fw now does the work.
    #
    # Also removed from the old chain:
    #   -p tcp --tcp-flags ACK ACK -j ACCEPT
    #       accepted any ACK-flagged packet regardless of conntrack state,
    #       making the host fully mappable by an nmap ACK scan and accepting
    #       out-of-state ACK/FIN/RST floods.
    #   -p udp/tcp --sport 53 -j ACCEPT
    #       unnecessary; conntrack already accepts DNS replies as ESTABLISHED,
    #       and a source port is trivially spoofed.
    #   -s 10.1.0.0/16 -j ACCEPT
    #       no interface qualifier, on a host with rp_filter disabled on the
    #       docker bridges. Pod->host traffic is covered by trustedInterfaces.

    extraCommands = ''
      # FORWARD: let Docker's own chains do their job.
      #
      # This previously read:
      #   iptables -I FORWARD 1 -i br+ -j ACCEPT
      #   iptables -I FORWARD 2 -o br+ -j ACCEPT
      # Inserted at positions 1-2 they sat above DOCKER-USER, DOCKER-FORWARD
      # and the per-bridge `! -i br-X -o br-X -j DROP` rules, which meant:
      #   * every Docker-published port was reachable from the internet
      #     regardless of networking.firewall (RabbitMQ 5672/15672 with
      #     guest:guest admin was live on 78.46.96.138), and
      #   * any neighbour on the Hetzner /27 could route 172.16.0.0/12 via
      #     this host and reach every container IP directly, including
      #     php-fpm on 9000 (unauthenticated RCE), MariaDB 3306,
      #     OpenSearch 9200 and Valkey 6379.
      # Docker's DOCKER chain already ACCEPTs published ports and DROPs
      # everything else inbound to a bridge, so no replacement is needed.
      iptables -C FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null \
        || iptables -I FORWARD 1 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      # Disable rp_filter on docker bridges.
      # Kept from the original config: the media stack routes through the
      # `warp` container's namespace, which produces asymmetric paths that
      # strict reverse-path filtering drops.
      for br in $(ip link show type bridge | grep -o "br-[a-f0-9]*"); do
        sysctl -w net.ipv4.conf.$br.rp_filter=0 2>/dev/null || true
      done
    '';

    extraStopCommands = ''
      # Only remove what extraCommands added.
      #
      # This previously ran `$cmd -F OUTPUT` for both iptables and ip6tables,
      # which flushed the entire filter OUTPUT chain on every firewall
      # restart -- including rules Docker and Kubernetes had installed.
      iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT 2>/dev/null || true
    '';
  };
}
