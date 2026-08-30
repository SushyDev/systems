{ ... }:
{
  programs.nano.enable = false;

  # --- Other
  programs.fuse.userAllowOther = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
