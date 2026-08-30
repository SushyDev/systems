# Which Plasma shell this system runs. Both shells sit on the same Plasma 6
# workspace -- kwin, plasma-workspace, SDDM, the portals and the PAM stack are
# shared -- so the choice is a shell swap, not a stack swap, and the parts of
# nixos-sheng that key off SDDM (the rotating, fingerprint-aware greeter) keep
# working either way.
#
# An option rather than a pair of imports because specialisations inherit their
# parent's imports and cannot drop one: `sheng.desktop.shell = "plasma-mobile"`
# is a value a child can override, whereas `imports` is not.
{ lib, pkgs, ... }:
{
  imports = [
    ./plasma-desktop.nix
    ./plasma-mobile.nix
  ];

  options.sheng.desktop.shell = lib.mkOption {
    type = lib.types.enum [
      "plasma-desktop"
      "plasma-mobile"
    ];
    default = "plasma-desktop";
    description = ''
      The Plasma shell to run. `plasma-desktop` is the ordinary Plasma 6
      desktop; `plasma-mobile` is the touch-first shell, which drops the
      panel and window decorations for a homescreen, an edge-swipe task
      switcher and full-screen apps.
    '';
  };

  config = {
    services.desktopManager.plasma6.enable = true;

    # Enabling SDDM is what switches nixos-sheng's greeter fixes on. Wayland,
    # since Plasma 6's X11 session has no working touch rotation.
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;

      # Both are needed: SDDM has its own Qt plugin path, so systemPackages
      # does not reach it, and the greeter only loads an input method it is
      # told to.
      extraPackages = [ pkgs.kdePackages.qtvirtualkeyboard ];
      settings.General.InputMethod = "qtvirtualkeyboard";
    };

    services.dbus.enable = true;
    services.udisks2.enable = true;
    services.upower.enable = true;

    services.pipewire = {
      enable = true;
      pulse.enable = true;
      # Route ALSA-only clients through PipeWire too, so they reach the same
      # UCM-configured sinks nixos-sheng sets up rather than opening the raw
      # PCM nodes. No support32Bit: aarch64 has no 32-bit personality here.
      alsa.enable = true;
    };

    # nixos-sheng already forces services.xserver.enable = false, so the only
    # X11 left is Xwayland, which plasma6 turns on for apps with no Wayland
    # backend. Chromium and Electron do have one but default to X11 unless
    # told otherwise -- this is what makes Vivaldi a native Wayland client.
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    # Dead weight rather than a fallback: with services.xserver.enable false
    # the sddm module writes no [X11] SessionDir, so plasmax11.desktop is
    # never offered and nothing can start kwin_x11.
    environment.plasma6.excludePackages = [ pkgs.kdePackages.kwin-x11 ];

    environment.systemPackages = [
      pkgs.kdePackages.plasma-pa

      # maliit-keyboard is top-level, not under kdePackages.
      pkgs.maliit-keyboard
      pkgs.kdePackages.qtvirtualkeyboard
    ];
  };
}
