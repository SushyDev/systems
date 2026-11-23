{ config, pkgs, ... }:
let
  # Rendered at build time from the pinned nixpkgs fluxcd package, so:
  #   * nothing is fetched at deploy time -- `flux install --export` embeds its
  #     manifests in the CLI binary, verified to work inside the build sandbox,
  #   * no 324 KB of generated YAML is committed to this repo,
  #   * Flux's version tracks `nix flake update` like everything else, instead
  #     of being a number someone has to remember to bump.
  #
  # image-reflector-controller and image-automation-controller are included:
  # they are what will watch GHCR for new Nix-built Magento images and write the
  # tag bump back to the GitOps repo. Flux cannot see a locally-imported image,
  # so a registry is on the path either way.
  fluxManifest = pkgs.runCommand "flux-install.yaml" { } ''
    export HOME=$TMPDIR
    ${pkgs.fluxcd}/bin/flux install --export \
      --components-extra=image-reflector-controller,image-automation-controller \
      > $out
  '';
in
{
  # --- Flux (GitOps for k3s)
  #
  # Installed through k3s's own auto-deploy manifests directory rather than
  # `flux bootstrap`. Bootstrap is an imperative command that writes to a git
  # repo and applies to the cluster as a side effect; this is a declarative
  # equivalent that survives a cluster rebuild with no operator action.
  #
  # NOTE: this installs the controllers only. It deliberately does NOT define a
  # GitRepository or Kustomization yet -- the cluster runs empty first so the
  # restart counters can be watched. The previous cluster restarted its control
  # plane every 30 minutes for 150 days while reporting NRestarts=0, and no
  # workload should be trusted to it until a soak proves otherwise.
  services.k3s.manifests.flux.source = fluxManifest;

  # The age identity kustomize-controller uses to decrypt SOPS-encrypted
  # manifests in the GitOps repo, rendered straight from sops into a Secret.
  #
  # The data key MUST end in `.agekey` -- kustomize-controller globs for that
  # suffix and silently ignores anything else, which presents as "decryption
  # failed" with no indication that the key was never read.
  sops.templates."flux-sops-age.yaml".content = ''
    apiVersion: v1
    kind: Secret
    metadata:
      name: sops-age
      namespace: flux-system
    type: Opaque
    stringData:
      age.agekey: "${config.sops.placeholder."flux/age_key"}"
  '';

  services.k3s.manifests.flux-sops-age.source =
    config.sops.templates."flux-sops-age.yaml".path;

  # Read-only deploy key for the GitOps repo.
  #
  # Stored base64-encoded in sops and emitted into `data:` rather than
  # `stringData:`. An OpenSSH private key is multi-line, and round-tripping raw
  # newlines through sops set / YAML scalars silently corrupts it -- the first
  # attempt produced a key that ssh-keygen rejected outright. Base64 is a single
  # line, and `data:` is base64 anyway, so nothing has to survive quoting.
  sops.templates."flux-git-auth.yaml".content = ''
    apiVersion: v1
    kind: Secret
    metadata:
      name: flux-git-auth
      namespace: flux-system
    type: Opaque
    data:
      identity: "${config.sops.placeholder."flux/deploy_key_b64"}"
      identity.pub: "${config.sops.placeholder."flux/deploy_key_pub_b64"}"
      known_hosts: "${config.sops.placeholder."flux/github_known_hosts_b64"}"
  '';

  services.k3s.manifests.flux-git-auth.source =
    config.sops.templates."flux-git-auth.yaml".path;

  # The GitRepository and root Kustomization live here rather than in the repo
  # itself, which is what makes `flux bootstrap` unnecessary: a rebuilt cluster
  # reconnects to the repo from Nix alone, with no operator action.
  #
  # prune = true so deleting a manifest from git deletes it from the cluster.
  # decryption points at the sops-age Secret above.
  # Declared as attrsets, not a YAML string: `manifests.<n>.content` is typed as
  # a list of attribute sets. That is also the safer form -- the module
  # serialises through JSON, and long multi-line strings get their "\n" escapes
  # corrupted by YAML line folding (see ./falco.nix for where that bit).
  services.k3s.manifests.flux-sync.content = [
    {
      apiVersion = "source.toolkit.fluxcd.io/v1";
      kind = "GitRepository";
      metadata = {
        name = "pulsar-gitops";
        namespace = "flux-system";
      };
      spec = {
        interval = "1m";
        url = "ssh://git@github.com/SushyDev/pulsar-gitops.git";
        ref.branch = "main";
        secretRef.name = "flux-git-auth";
      };
    }
    {
      apiVersion = "kustomize.toolkit.fluxcd.io/v1";
      kind = "Kustomization";
      metadata = {
        name = "pulsar";
        namespace = "flux-system";
      };
      spec = {
        interval = "10m";
        retryInterval = "1m";
        timeout = "5m";
        path = "./clusters/pulsar";
        # Deleting a manifest from git deletes it from the cluster.
        prune = true;
        wait = true;
        sourceRef = {
          kind = "GitRepository";
          name = "pulsar-gitops";
        };
        decryption = {
          provider = "sops";
          secretRef.name = "sops-age";
        };
      };
    }
  ];

  environment.systemPackages = [ pkgs.fluxcd ];
}
