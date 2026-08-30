{ nixpkgs, pkgs, ... }:
{
  # nixos-sheng's shengSystem already sets allowUnfree (the QTEE bits and
  # the vendor firmware blobs are proprietary), so it is not repeated here.

  environment.systemPackages = [
    pkgs.ghostty
    pkgs.mkcert
    pkgs.opencode
    pkgs.vivaldi
    pkgs.xdg-utils

    # Camera apps. Both drive GStreamer, which is the path verified to
    # work here: gst-device-monitor lists the three libcamera cameras via
    # pipewiresrc, with correct front/back location metadata. qrca (Qt
    # multimedia) cannot consume either libcamera or PipeWire on this
    # build and reports "camera is not supported on the platform", so it
    # is not a useful test of whether the cameras work.
    pkgs.snapshot
    pkgs.kdePackages.kamoso

    # Provides libcamerify plus v4l2-compat.so, the shim that presents
    # libcamera cameras to V4L2-only applications:
    #   LD_PRELOAD=.../libexec/libcamera/v4l2-compat.so <app>
    pkgs.libcamera

    # Dropped from pc's list because they have no aarch64-linux build:
    # spotify, discord-ptb, mpv. Checked against nixos-unstable, not
    # assumed -- meta.platforms omits aarch64-linux for all three.
    #
    # spotify in particular is x86_64-linux + aarch64-darwin only: it is
    # a repackaged upstream binary, and there is no aarch64 Linux one to
    # repackage. Adding it back does not merely warn, it aborts the
    # evaluation with "Package is not supported on aarch64-linux", so the
    # whole system stops building. ncspot or spotify-player are the
    # buildable alternatives if you want playback on the tablet.
    #
    # ddev and dbeaver-bin do build for aarch64, but they are heavy local
    # dev tooling that wants a docker daemon; left off a tablet on purpose.
  ];

  fonts.packages = [
    pkgs.fira-code
  ];
}
