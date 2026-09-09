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

  environment.systemPackages = [ pkgs.fluxcd ];
}
