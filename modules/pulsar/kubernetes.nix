{ pkgs, config, lib, ... }:
{
  services.kubernetes = {
    roles = ["master" "node"];
    masterAddress = config.networking.hostName;
    easyCerts = true;
    apiserverAddress = "https://${config.networking.hostName}:6443";

    addons.dns.enable = true;

    kubelet.extraOpts = "--fail-swap-on=false";
  };

  networking.extraHosts = "127.0.0.1 ${config.networking.hostName}";

  networking.firewall.trustedInterfaces = [
    "mynet"
    "cni0"
    "flannel.1"
  ];

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

  # Standard packages for management
  environment.systemPackages = [
    pkgs.kubectl
    pkgs.kubernetes
  ];
}
