{ setup, ... }:
{
  imports = [ ../../shared/nix.nix ];

  # Rebuilding the kernel on the tablet is the slow path this exists for.
  sheng.buildCache.enable = true;

  # nixos-rebuild --sudo runs the client as the calling user, and an untrusted
  # client has its builder settings (the ccache sandbox path included) dropped
  # with only a warning.
  nix.settings.trusted-users = setup.managedUsersAndRoot;

  # pc over binfmt was slower than building here: ~17 min locally against 70+
  # min emulated.
  nix.distributedBuilds = false;

  nix.settings = {
    fallback = true;
    builders-use-substitutes = true;
  };
}
