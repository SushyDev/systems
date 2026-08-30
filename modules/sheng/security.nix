{
  setup,
  ...
}:
{
  security.sudo.wheelNeedsPassword = false;

  # RTKit for PipeWire real-time audio priority
  security.rtkit.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    # Plasma needs the PolKit integration for CLI/system auth.
    polkitPolicyOwners = setup.managedUsers;
  };

  environment.etc = {
    "1password/custom_allowed_browsers" = {
      text = "vivaldi-bin";
      mode = "0755";
    };
  };

  programs.fuse.userAllowOther = true;
}
