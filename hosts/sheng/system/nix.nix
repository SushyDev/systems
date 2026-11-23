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

    # One build at a time on all cores: the kernel keeps its speed, but two
    # heavy builds can no longer stack their peak memory.
    max-jobs = 1;
    cores = 0;

    # The trait's 2G is an in-memory buffer; here that is a quarter of RAM.
    download-buffer-size = 268435456;
  };
}
