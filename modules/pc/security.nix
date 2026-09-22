{ ... }:
{
  # Enable RTKit for PipeWire real-time audio priority
  security.rtkit.enable = true;

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = "vivaldi-bin";
      mode = "0755";
    };
  };

  programs.fuse.userAllowOther = true;
}
