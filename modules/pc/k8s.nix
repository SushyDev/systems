{
  config,
  pkgs,
  lib,
  ...
}:

{
  # OpenSearch requires vm.max_map_count >= 262144
  boot.kernel.sysctl."vm.max_map_count" = 262144;

  # Trust pod network interfaces so pods can reach the host (kube-apiserver, kubelet, etc.)
  # Without this, the NixOS firewall blocks pod→host traffic in INPUT, breaking CoreDNS sync.
  networking.firewall.trustedInterfaces = [
    "mynet"
    "cni0"
    "flannel.1"
  ];

  # Open kube-apiserver port so in-cluster DNAT (10.0.0.1:443 → host:6443) is not refused.
  networking.firewall.allowedTCPPorts = [
    6443
    10250
  ];

  services.kubernetes = {
    roles = [
      "master"
      "node"
    ];
    masterAddress = "localhost";
    easyCerts = true;
    addons.dns.enable = true;
    kubelet.extraOpts = "--fail-swap-on=false";
  };

  # Create hostPath directories for persistent pod storage, and fix cluster-admin-key permissions.
  system.activationScripts.k8s-data-dirs = lib.stringAfter [ "var" ] ''
    mkdir -p /data/mariadb /data/opensearch /data/keydb-cache /data/keydb-session /data/magento-webroot
    chmod 0777 /data/mariadb /data/opensearch /data/keydb-cache /data/keydb-session /data/magento-webroot

    # Allow the kubernetes group (and sushy) to read the cluster-admin key without sudo.
    KEY=/var/lib/kubernetes/secrets/cluster-admin-key.pem
    [ -f "$KEY" ] && chmod 0640 "$KEY"
  '';

  # Permanently fix the flannel ClusterRole RBAC bug (missing "get" on nodes).
  # Runs once after kube-apiserver is healthy; idempotent patch is safe to re-run.
  systemd.services.flannel-rbac-patch = {
    description = "Patch flannel ClusterRole to add get on nodes";
    wantedBy = [ "multi-user.target" ];
    after = [ "kube-apiserver.service" ];
    requires = [ "kube-apiserver.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10";
      ExecStart = pkgs.writeShellScript "flannel-rbac-patch" ''
        export KUBECONFIG=/etc/kubernetes/cluster-admin.kubeconfig
        until ${pkgs.kubectl}/bin/kubectl get clusterrole flannel &>/dev/null; do
          echo "Waiting for flannel ClusterRole..."
          sleep 5
        done
        ${pkgs.kubectl}/bin/kubectl patch clusterrole flannel --type=json \
          -p='[{"op":"replace","path":"/rules/1/verbs","value":["get","list","watch"]}]'
        echo "flannel ClusterRole patched."
      '';
    };
  };

  environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";

  environment.systemPackages = with pkgs; [
    kubectl
    kubernetes-helm
    k9s
  ];
}
