{ setup, ... }:
{
  imports = [ ../../shared/nix.nix ];

  # nixos-rebuild --sudo runs the client as the calling user, and an untrusted
  # client has its builder settings dropped with only a warning.
  nix.settings.trusted-users = setup.managedUsersAndRoot;

  # pc over binfmt was slower than building here: ~17 min locally against 70+
  # min emulated.
  nix.distributedBuilds = false;

  nix.settings = {
    fallback = true;
    builders-use-substitutes = true;
  };
}
