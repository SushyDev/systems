{ ... }:
{
  # --- Secrets (sops-nix)
  #
  # Chosen over the 1Password Kubernetes operator / External Secrets / op-run
  # for three reasons:
  #
  #   * it is the only option that covers every surface this host has -- compose
  #     .env files, NixOS module options that want a *File path, and later Flux's
  #     in-cluster decryption -- with one mechanism,
  #   * it adds no long-running process. Decryption happens once at activation;
  #     there is nothing to be down at 3am and nothing to rate-limit,
  #   * the 1Password operator cannot bootstrap its own credential. It needs a
  #     service-account token to already be a Kubernetes Secret before it can
  #     fetch anything, so a host-side store is required either way.
  #
  # 1Password is still involved, but as KEY CUSTODY rather than a runtime API:
  # the admin age private key lives there, and is what recovers these secrets
  # onto a rebuilt host. See ../../.sops.yaml for both recipients.
  #
  # Decryption on this host uses the existing SSH host key via ssh-to-age, so no
  # additional private key has to be provisioned or backed up for pulsar itself.

  sops = {
    defaultSopsFile = ./secrets/pulsar.yaml;

    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Do not look for a plain age key file; the host key above is the only
    # decryption path. Without this, sops-nix also probes ~/.config/sops/age.
    age.keyFile = null;

    secrets = {
      # Consumed by services.restic.backups.*.passwordFile.
      "restic/password" = { };

      # The single alerting channel. Rendered to /run/secrets/... and read by
      # systemd OnFailure= handlers.
      "alerting/discord_webhook" = { };

      # The age identity Flux's kustomize-controller uses to decrypt SOPS files
      # in the GitOps repo. It is a THIRD key, distinct from the two in
      # ../../.sops.yaml:
      #
      #   admin   -- edits this file, recovers it onto a rebuilt host, in 1Password
      #   pulsar  -- the host's ssh_host_ed25519_key, decrypts this file at activation
      #   cluster -- the key below, decrypts secrets in the GitOps repo
      #
      # Layering it this way means the cluster key is itself protected by the
      # host key, so it never exists in plaintext outside /run, and a compromise
      # of the cluster does not hand over the ability to decrypt host secrets.
      "flux/age_key" = { };
      "flux/deploy_key_b64" = { };
      "flux/deploy_key_pub_b64" = { };
      "flux/github_known_hosts_b64" = { };
    };
  };
}
