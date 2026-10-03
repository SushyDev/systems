# sd-boot with the multi-display + XInput gamepad patches, built as a standalone EFI binary.
#
# Deliberately NOT exposed as systemd.package: that would rebuild everything that depends on
# systemd. We only want the ~250 kB EFI binary, so we reuse systemd's build inputs but ask ninja
# for the `systemd-boot` alias target only (src/boot/meson.build), which skips all of userspace.
{
  lib,
  systemd,
  stdenv,
}:
let
  efiArch = stdenv.hostPlatform.efiArch;
in
# The patches carry upstream context; a systemd bump should fail loudly rather than half-apply.
assert lib.assertMsg
  (lib.versionAtLeast systemd.version "261" && lib.versionOlder systemd.version "262")
  "sd-boot-multigop patches are against systemd 261.x, but nixpkgs has ${systemd.version}. Rebase the patch series next to this file first.";

systemd.overrideAttrs (prev: {
  pname = "sd-boot-multigop";

  patches = (prev.patches or [ ]) ++ [
    ./patches/0001-sd-boot-mirror-the-menu-across-every-display.patch
    ./patches/0002-sd-boot-accept-input-from-XInput-gamepads.patch
  ];

  outputs = [ "out" ];

  # Only the bootloader, not systemd.
  ninjaFlags = (prev.ninjaFlags or [ ]) ++ [ "systemd-boot" ];

  # systemd's own install/fixup/check steps all assume a full build.
  postInstall = "";
  postFixup = "";
  doCheck = false;
  doInstallCheck = false;

  installPhase = ''
    runHook preInstall
    efi=$(find . -type f -name "systemd-boot${efiArch}.efi" -print -quit)
    [ -n "$efi" ] || { echo "no systemd-boot${efiArch}.efi was produced"; exit 1; }
    install -Dm0644 "$efi" -t "$out"
    runHook postInstall
  '';

  meta = prev.meta // {
    description = "systemd-boot patched to mirror its menu across all displays and accept XInput gamepads";
  };
})
