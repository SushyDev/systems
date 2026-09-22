{ trait, lib, ... }:
let
  settings = import ./settings.nix { inherit lib; };
in
{
  config =
    if trait.capabilities.determinateNix then
      {
        determinateNix.customSettings = settings;
        determinateNix.determinateNixd.garbageCollector.strategy = lib.mkDefault "automatic";
      }
    else
      {
        nix.settings = settings;
        nix.gc.automatic = lib.mkDefault true;
      };
}
