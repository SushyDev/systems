{ pkgs, ... }:
{
  # --- Kubernetes (k3s)
  #
  # Replaces the previous native `services.kubernetes` deployment (see
  # ./kubernetes.nix in git history, removed 2026-09-09).
  #
  # Why the old one was removed, precisely: it used `easyCerts = true`, i.e.
  # cfssl + certmgr for PKI. certmgr's generated cert specs put Kubernetes
  # usernames into the SAN list, e.g.
  #     kubeProxyClient.json -> {"hosts": ["system:kube-proxy"]}
  # A colon is not a valid DNS name, IP, email or URI, so cfssl silently drops
  # the entry. The issued certificate therefore never matched the spec, certmgr
  # concluded "spec DNS name has changed" on every 30-minute check, re-issued,
  # and ran that spec's action -- `systemctl restart kube-apiserver`.
  #
  # Net effect: the control plane restarted every ~30 minutes for 150 days while
  # systemd reported NRestarts=0 and ActiveState=active, so nothing ever alerted.
  # certmgr has had no upstream release since 2019, so this is not getting fixed.
  #
  # k3s removes that entire class of problem and three others with it:
  #   * it manages its own PKI, so no cfssl (which also listened on *:8888) and
  #     no certmgr,
  #   * it ships local-path-provisioner as a default StorageClass -- the old
  #     cluster had NO StorageClass at all, so no PVC could ever bind,
  #   * it needs no hand-written flannel ClusterRole patch unit.

  services.k3s = {
    enable = true;
    role = "server";
    nodeName = "pulsar";

    # traefik   -- ingress is not used. cloudflared runs inside the cluster and
    #              dials ClusterIP Services directly, so there is no ingress
    #              controller and no host port to expose.
    # servicelb -- nothing requests a LoadBalancer Service; klipper-lb would only
    #              add host-port plumbing we do not want on a public IP.
    disable = [
      "traefik"
      "servicelb"
    ];

    extraFlags = [
      # Let a member of the `k3s` group read the admin kubeconfig without sudo.
      # Default is 0600 root:root, which is why `kubectl` as sushy previously
      # failed with a permission error against the old cluster.
      "--write-kubeconfig-mode=0640"

      # Swap is enabled on this host (zramSwap + 31G disk swap); do not refuse
      # to start because of it. Matches the old kubelet --fail-swap-on=false.
      "--kubelet-arg=fail-swap-on=false"
    ];
  };

  # The API server binds 0.0.0.0 by default. It is kept off the internet by the
  # firewall, NOT by a bind address: ./networking.nix lists only port 22 in
  # allowedTCPPorts. Binding to loopback instead is tempting but breaks the
  # in-cluster `kubernetes.default.svc` endpoint, which pods (Flux, cloudflared)
  # need to reach.
  #
  # Pod- and node-network traffic to the host is allowed by interface instead.
  # k3s uses cni0 + flannel.1; `mynet` was the old flannel bridge and is gone.
  networking.firewall.trustedInterfaces = [
    "cni0"
    "flannel.1"
  ];

  # Group-readable kubeconfig, per --write-kubeconfig-mode above.
  users.groups.k3s = { };

  systemd.tmpfiles.rules = [
    "z /etc/rancher/k3s/k3s.yaml 0640 root k3s -"
  ];

  environment.systemPackages = [
    pkgs.kubectl
    pkgs.k9s
  ];
}
