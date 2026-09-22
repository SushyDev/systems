{ ... }:
{
  programs.nano.enable = false;
  programs.nix-ld.enable = true;

  # --- Other
  programs.fuse.userAllowOther = true;
}
