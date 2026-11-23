{ ... }:
{
  # Enable RTKit for PipeWire real-time audio priority
  security.rtkit.enable = true;

  programs.fuse.userAllowOther = true;
}
