{ lib, ... }:
{
  # Older generations symlinked this into the store, which rsync can't write through.
  system.activationScripts.applications.text = lib.mkBefore ''
    if [ -L /Applications/1Password.app ]; then
      rm /Applications/1Password.app
    fi
  '';
}
