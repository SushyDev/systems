{ config, pkgs, ... }:

{
  services.k3s = {
    enable = true;
    role = "server";
    extraFlags = toString [
      "--disable traefik"
      "--disable servicelb"
      "--write-kubeconfig-mode 644" # Allows your user to run kubectl without sudo
    ];
  };

  # Wait for a default route before k3s starts.
  # NetworkManager marks network-online.target before routes are fully
  # propagated, causing k3s to fail on first boot with "no default routes found".
  systemd.services.k3s.serviceConfig.ExecStartPre = [
    "${pkgs.bash}/bin/bash -c 'until ${pkgs.iproute2}/bin/ip route show default | grep -q default; do sleep 1; done'"
  ];

  # Set the KUBECONFIG env var so kubectl knows where to look
  environment.variables.KUBECONFIG = "/etc/rancher/k3s/k3s.yaml";

  environment.systemPackages = with pkgs; [
    k3s
    kubectl
    kubernetes-helm
    k9s # Highly recommended: a CLI UI for managing your cluster
  ];
}
