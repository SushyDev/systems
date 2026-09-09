{ ... }:
{
  programs.nano.enable = false;

  # --- Other
  # `enable` is required as of the 26.11 nixpkgs bump: programs.fuse gained an
  # mkEnableOption and its whole config block is now `lib.mkIf cfg.enable`.
  # Without it, setting userAllowOther alone silently produces no /etc/fuse.conf
  # and no setuid fusermount/fusermount3 wrappers, which breaks every FUSE
  # consumer on the host (fuse_video_streamer, debrid_drive).
  programs.fuse = {
    enable = true;
    userAllowOther = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
