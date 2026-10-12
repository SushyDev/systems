# A non-root operator login for the cluster.
#
# `kubeops` is not in wheel, docker or k3s (docker == root; the k3s group can
# read the admin kubeconfig). Its only power is the
# client certificate below, which Kubernetes maps to the group
# `pulsar:operators`; what that group may do is RBAC in the GitOps repo
# (infrastructure/rbac.yaml). Anything not granted there is denied.
{ pkgs, lib, ... }:
let
  user = "kubeops";
  home = "/home/${user}";
  caCert = "/var/lib/rancher/k3s/server/tls/server-ca.crt";
  clientCaCert = "/var/lib/rancher/k3s/server/tls/client-ca.crt";
  caKey = "/var/lib/rancher/k3s/server/tls/client-ca.key";
  server = "https://127.0.0.1:6443";
  validDays = 30;
  renewWithinDays = 14;

  mint = pkgs.writeShellScript "kubeops-kubeconfig" ''
    set -euo pipefail
    export PATH=${lib.makeBinPath [ pkgs.openssl pkgs.kubectl pkgs.coreutils ]}
    umask 077
    dir=${home}/.kube
    install -d -m 0700 -o ${user} -g ${user} "$dir"

    # Still valid for long enough: nothing to do.
    if [ -s "$dir/config" ] && [ -s "$dir/client.pem" ] \
       && openssl x509 -in "$dir/client.pem" -noout -checkend $((${toString renewWithinDays} * 86400)); then
      exit 0
    fi

    work=$(mktemp -d)
    trap 'rm -rf "$work"' EXIT
    openssl ecparam -name prime256v1 -genkey -noout -out "$work/key.pem"
    openssl req -new -key "$work/key.pem" -subj "/CN=${user}/O=pulsar:operators" -out "$work/csr.pem"
    printf 'keyUsage=critical,digitalSignature\nextendedKeyUsage=clientAuth\n' > "$work/ext"
    openssl x509 -req -in "$work/csr.pem" -CA ${clientCaCert} -CAkey ${caKey} -CAcreateserial \
      -CAserial "$work/ca.srl" -days ${toString validDays} -extfile "$work/ext" -out "$work/client.pem"

    kubectl config --kubeconfig="$work/config" set-cluster pulsar \
      --server=${server} --certificate-authority=${caCert} --embed-certs=true
    kubectl config --kubeconfig="$work/config" set-credentials ${user} \
      --client-certificate="$work/client.pem" --client-key="$work/key.pem" --embed-certs=true
    kubectl config --kubeconfig="$work/config" set-context pulsar --cluster=pulsar --user=${user}
    kubectl config --kubeconfig="$work/config" use-context pulsar

    install -m 0600 -o ${user} -g ${user} "$work/config" "$dir/config"
    install -m 0600 -o ${user} -g ${user} "$work/client.pem" "$dir/client.pem"
  '';
in
{
  users.users.${user} = {
    isNormalUser = true;
    description = "Least-privilege Kubernetes operator";
    home = home;
    # No password, no wheel, no docker, no k3s group.
    extraGroups = [ ];
    openssh.authorizedKeys.keys = [
      # Same key as sushy for now; swap for a dedicated key to separate them.
      "no-port-forwarding,no-agent-forwarding,no-X11-forwarding ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDK2znreT4nuwGavrkejyLgVUvVeSgL/9T/+wXOZdhOr"
    ];
  };

  # The global KUBECONFIG points at the k3s admin config; this user must not use it.
  environment.extraInit = ''
    if [ "$USER" = "${user}" ]; then export KUBECONFIG="$HOME/.kube/config"; fi
  '';

  # Mint (and renew) the operator's client certificate. Root signs it with the
  # cluster CA; the result is owned by the user, the CA key never leaves root.
  systemd.services.kubeops-kubeconfig = {
    description = "Issue the ${user} Kubernetes client certificate";
    after = [ "k3s.service" ];
    wants = [ "k3s.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = mint;
      ProtectSystem = "strict";
      ReadWritePaths = [ home ];
      PrivateTmp = true;
      ProtectKernelTunables = true;
      ProtectControlGroups = true;
      NoNewPrivileges = true;
      RestrictAddressFamilies = [ "AF_UNIX" ];
    };
  };
  systemd.timers.kubeops-kubeconfig = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };
  };
}
