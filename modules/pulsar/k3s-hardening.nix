# k3s API-server hardening: audit trail and cluster-wide Pod Security defaults.
{ pkgs, ... }:
let
  # Metadata for everything (who did what, never request/response bodies, so
  # Secrets cannot leak into the log); nothing for the noisy read-only paths.
  auditPolicy = pkgs.writeText "audit-policy.yaml" ''
    apiVersion: audit.k8s.io/v1
    kind: Policy
    omitStages: ["RequestReceived"]
    rules:
      - level: None
        users: ["system:kube-proxy"]
        verbs: ["watch"]
      - level: None
        nonResourceURLs: ["/healthz*", "/livez*", "/readyz*", "/version", "/metrics"]
      - level: None
        resources:
          - group: ""
            resources: ["events"]
      - level: Metadata
  '';

  # Opt-in model: every namespace is held to `baseline` unless labelled
  # otherwise, and warned/audited against `restricted`. Exempt namespaces are
  # the ones that genuinely need host access: kube-system (k3s add-ons) and
  # falco (privileged eBPF sensor, installed by falco.nix).
  psaConfig = pkgs.writeText "psa-config.yaml" ''
    apiVersion: apiserver.config.k8s.io/v1
    kind: AdmissionConfiguration
    plugins:
      - name: PodSecurity
        configuration:
          apiVersion: pod-security.admission.config.k8s.io/v1
          kind: PodSecurityConfiguration
          defaults:
            enforce: baseline
            enforce-version: latest
            audit: restricted
            audit-version: latest
            warn: restricted
            warn-version: latest
          exemptions:
            usernames: []
            runtimeClasses: []
            namespaces: ["kube-system", "falco"]
  '';
in
{
  services.k3s.extraFlags = [
    "--pod-security-admission-config-file=${psaConfig}"
    "--kube-apiserver-arg=audit-policy-file=${auditPolicy}"
    "--kube-apiserver-arg=audit-log-path=/var/log/kubernetes/audit.log"
    "--kube-apiserver-arg=audit-log-maxage=30"
    "--kube-apiserver-arg=audit-log-maxbackup=5"
    "--kube-apiserver-arg=audit-log-maxsize=100"
    "--kube-apiserver-arg=profiling=false"
  ];

  systemd.tmpfiles.rules = [ "d /var/log/kubernetes 0750 root root -" ];
}
