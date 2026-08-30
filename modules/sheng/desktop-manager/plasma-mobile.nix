# Plasma Mobile: the same Plasma 6 workspace with the touch shell in place of
# the desktop one -- a homescreen, an edge-swipe task switcher, full-screen
# apps and no panel or window decorations. Selected by sheng.desktop.shell, the
# shared workspace plumbing lives in ./default.nix.
{ config, lib, pkgs, ... }:
lib.mkIf (config.sheng.desktop.shell == "plasma-mobile") {
  # plasma-mobile carries passthru.providedSessions, so registering the package
  # is all SDDM needs to offer the session; plasma6.nix only mkDefaults
  # defaultSession, so this wins without a mkForce.
  services.displayManager.sessionPackages = [ pkgs.kdePackages.plasma-mobile ];
  services.displayManager.defaultSession = "plasma-mobile";

  environment.systemPackages = [
    pkgs.kdePackages.plasma-mobile

    # The shell's own QML imports. plasma6.nix installs qtsensors only when
    # hardware.sensor.iio is on, and nixos-sheng runs its own vendored
    # iio-sensor-proxy instead of that module -- so rotation would find no
    # QtSensors plugin. kirigami-addons is a build dependency of the shell
    # that plasmashell, being wrapped separately, does not otherwise see.
    pkgs.kdePackages.qtsensors
    pkgs.kdePackages.kirigami-addons

    # Touch-first replacements for the desktop apps excluded below. Trim
    # freely; the shell does not depend on any of them.
    pkgs.kdePackages.angelfish
    pkgs.kdePackages.qmlkonsole
    pkgs.kdePackages.koko
    pkgs.kdePackages.kclock
    pkgs.kdePackages.kalk
  ];

  # Everything here is pointer-and-keyboard shaped: it either has no touch
  # layout at all or duplicates something the shell already provides.
  environment.plasma6.excludePackages = [
    pkgs.kdePackages.aurorae
    pkgs.kdePackages.ark
    pkgs.kdePackages.dolphin
    pkgs.kdePackages.elisa
    pkgs.kdePackages.gwenview
    pkgs.kdePackages.kate
    pkgs.kdePackages.khelpcenter
    pkgs.kdePackages.kinfocenter
    pkgs.kdePackages.konsole
    pkgs.kdePackages.okular
    pkgs.kdePackages.oxygen
    pkgs.kdePackages.plasma-browser-integration
    pkgs.kdePackages.spectacle
  ];
}
