{ ... }:
{
  # Rebuilding the kernel on the tablet is the slow path this exists for.
  sheng.buildCache.enable = true;

  # pc over binfmt was slower than building here: ~17 min locally against 70+
  # min emulated.
  nix.distributedBuilds = false;

  nix.settings = {
    fallback = true;
    builders-use-substitutes = true;
  };
}
