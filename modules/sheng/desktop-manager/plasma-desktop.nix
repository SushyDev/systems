# The ordinary Plasma 6 desktop. Selected by sheng.desktop.shell, the shared
# workspace plumbing lives in ./default.nix.
{ config, lib, pkgs, ... }:
lib.mkIf (config.sheng.desktop.shell == "plasma-desktop") {
  # plasma-workspace.sessions names it "plasma"; plasma6.nix only mkDefaults it,
  # so this wins without a mkForce.
  services.displayManager.defaultSession = "plasma";

  environment.plasma6.excludePackages = [
    pkgs.kdePackages.elisa
    pkgs.kdePackages.oxygen
    pkgs.kdePackages.okular
    pkgs.kdePackages.khelpcenter
    pkgs.kdePackages.kinfocenter
    pkgs.kdePackages.gwenview
  ];
}
