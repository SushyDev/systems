{ ... }:
{
  programs.nano.enable = false;
  programs.nix-ld.enable = true;

  # --- Other
  programs.fuse.userAllowOther = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
