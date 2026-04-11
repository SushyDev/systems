{
  setup,
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./bootloader.nix
    ./packages.nix
    ./programs.nix
    ./security.nix
    ./services.nix

    ./system/default.nix
    ../shared/oxidation.nix
  ];

  # --- System
  system.stateVersion = "25.05";

  # --- Swap
  #swapDevices = lib.mkForce [];

  # --- Networking
  networking.hostName = "pulsar";
  networking.firewall = {
    enable = true;

    # INCOMING: Match Hetzner - SSH, Established, ICMP, Drop all
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ ];

    extraCommands = ''
      			for cmd in iptables ip6tables; do
      			# INPUT: Match Hetzner rules
      			# 1. Loopback
      			$cmd -A INPUT -i lo -j ACCEPT

      			# 2. ESTABLISHED,RELATED
      			$cmd -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

      			# 3. SSH (22)
      			if [ "$cmd" = "iptables" ]; then
      			  $cmd -A INPUT -p tcp --dport 22 -j ACCEPT
      			else
      			  $cmd -A INPUT -p tcp --dport 22 -j ACCEPT
      			fi

      			# 4. TCP Replies (ACK flag)
      			$cmd -A INPUT -p tcp --tcp-flags ACK ACK -j ACCEPT

      			# 5. DNS Replies (port 53)
      			$cmd -A INPUT -p udp --sport 53 -j ACCEPT
      			$cmd -A INPUT -p tcp --sport 53 -j ACCEPT

      			# 6. ICMP
      			if [ "$cmd" = "iptables" ]; then
      			  $cmd -A INPUT -p icmp -j ACCEPT
      			else
      			  $cmd -A INPUT -p ipv6-icmp -j ACCEPT
      			fi

      			# 7. DROP everything else
      			$cmd -A INPUT -j DROP
      			done

      			# OUTPUT: Allow all (like Hetzner)
      			for cmd in iptables ip6tables; do
      			  $cmd -A OUTPUT -j ACCEPT
      			done

      			# FORWARD: Allow all Docker bridge traffic
      			iptables -I FORWARD 1 -i br+ -j ACCEPT
      			iptables -I FORWARD 2 -o br+ -j ACCEPT
      			iptables -I FORWARD 3 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

      			# Disable rp_filter on docker bridges
      			for br in $(ip link show type bridge | grep -o 'br-[a-f0-9]*'); do
      			 sysctl -w net.ipv4.conf.$br.rp_filter=0 2>/dev/null || true
      			done
      		'';

    # Ensure these rules are cleared if the firewall stops/restarts
    extraStopCommands = ''
      			for cmd in iptables ip6tables; do
      			# INPUT cleanup
      			$cmd -D INPUT -i lo -j ACCEPT || true
      			$cmd -D INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT || true
      			$cmd -D INPUT -p tcp --dport 22 -j ACCEPT || true
      			$cmd -D INPUT -p tcp --tcp-flags ACK ACK -j ACCEPT || true
      			$cmd -D INPUT -p udp --sport 53 -j ACCEPT || true
      			$cmd -D INPUT -p tcp --sport 53 -j ACCEPT || true
      			if [ "$cmd" = "iptables" ]; then
      			  $cmd -D INPUT -p icmp -j ACCEPT || true
      			else
      			  $cmd -D INPUT -p ipv6-icmp -j ACCEPT || true
      			fi
      			$cmd -D INPUT -j DROP || true

      			# OUTPUT cleanup (allow all, so nothing to clean)
      			$cmd -F OUTPUT || true
      			done

      			# FORWARD cleanup
      			iptables -D FORWARD -i br+ -j ACCEPT || true
      			iptables -D FORWARD -o br+ -j ACCEPT || true
      			iptables -D FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT || true
      		'';
  };

  nixpkgs.config.allowUnfree = true;

  # --- Shared mount
  # systemd.mounts = [
  #   {
  #     # Bind mount the project directory onto itself to apply rshared
  #     # This is safer than applying it to the whole root filesystem.
  #     where = "/";
  #     what = "none"; # Source and destination are the same
  #     type = "none";
  #     options = "bind,rshared";
  #   }
  # ];
}
