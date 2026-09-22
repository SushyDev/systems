{ config, lib, ... }:
{
  programs._1password-gui.polkitPolicyOwners = lib.mkDefault (
    lib.attrNames (lib.filterAttrs (_name: user: user.isNormalUser) config.users.users)
  );
}
