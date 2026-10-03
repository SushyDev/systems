#!/usr/bin/env bash
# Boot the patched sd-boot under OVMF with two display heads and screenshot both.
# QEMU gives two real GOP handles, so mirroring and per-display mode selection are testable here.
# Connector hotplug is not: QEMU has no equivalent of HPD on an already-enumerated GPU.
#
# Usage: ./test-qemu.sh <systemd-bootx64.efi>

set -euo pipefail

EFI=${1:-}
WORK=${WORK:-/tmp/sdboot-test}
ESP=$WORK/esp
MON=$WORK/monitor.sock

if [ -z "$EFI" ]; then
  echo "usage: $0 <systemd-bootx64.efi>" >&2
  exit 1
fi

need() { command -v "$1" >/dev/null || { echo "need $1 (try: nix shell nixpkgs#$2)" >&2; exit 1; }; }
need qemu-system-x86_64 qemu
need socat socat
need magick imagemagick

OVMF_DIR=$(dirname "$(find /nix/store -maxdepth 4 -path '*OVMF*/FV/OVMF_CODE.fd' -print -quit)")
[ -n "$OVMF_DIR" ] || { echo "no OVMF found (try: nix build nixpkgs#OVMF.fd)" >&2; exit 1; }

rm -rf "$WORK"
mkdir -p "$ESP/EFI/BOOT" "$ESP/loader/entries"
install -m644 "$EFI" "$ESP/EFI/BOOT/BOOTX64.EFI"
printf 'timeout 300\nconsole-mode auto\nmultigop yes\ngamepad yes\n' > "$ESP/loader/loader.conf"
head -c 200000 /dev/urandom > "$ESP/dummy-kernel"
printf 'title NixOS Generation 42\nversion 6.18\nlinux /dummy-kernel\n' > "$ESP/loader/entries/a.conf"
printf 'title NixOS Generation 41 (rollback)\nversion 6.18\nlinux /dummy-kernel\n' > "$ESP/loader/entries/b.conf"
printf 'title Tiny 11 Pro\nefi /dummy-kernel\n' > "$ESP/loader/entries/c.conf"

install -m600 "$OVMF_DIR/OVMF_VARS.fd" "$WORK/vars.fd"

qemu-system-x86_64 -machine q35 -m 512 -nodefaults \
  -drive "if=pflash,format=raw,readonly=on,file=$OVMF_DIR/OVMF_CODE.fd" \
  -drive "if=pflash,format=raw,file=$WORK/vars.fd" \
  -drive "file=fat:rw:$ESP,format=raw,if=ide" \
  -device VGA,id=vga0,xres=1920,yres=1080 \
  -device secondary-vga,id=vga1,xres=1280,yres=720 \
  -display none -monitor "unix:$MON,server,nowait" &
QEMU_PID=$!
trap 'kill $QEMU_PID 2>/dev/null || true' EXIT

mon() { printf '%s\n' "$@" | socat - "UNIX-CONNECT:$MON" >/dev/null 2>&1; }

echo "waiting for the menu..."
until [ -S "$MON" ]; do sleep 0.5; done
for _ in $(seq 1 40); do
  mon "screendump $WORK/probe.ppm vga0" || true
  if [ -f "$WORK/probe.ppm" ] &&
     [ "$(magick identify -format '%[fx:mean>0.002]' "$WORK/probe.ppm" 2>/dev/null)" = 1 ]; then
    break
  fi
  sleep 1
done

# 'p' is sd-boot's status screen; the patch adds the display and gamepad lines to it. Retry it:
# right after the menu paints, the firmware is often not yet delivering key strokes.
echo "opening the status screen..."
for _ in $(seq 1 15); do
  mon "sendkey p"
  sleep 1
  mon "screendump $WORK/probe.ppm vga0" || true
  # the status screen is many more rows than the menu, so it trims much taller
  h=$(magick identify -format '%h' "$WORK/probe.ppm" 2>/dev/null || echo 0)
  rows=$(magick "$WORK/probe.ppm" -trim +repage -format '%h' info: 2>/dev/null || echo 0)
  [ "$rows" -gt 400 ] && break
done
for head in vga0 vga1; do
  mon "screendump $WORK/$head.ppm $head"
  magick "$WORK/$head.ppm" -trim +repage -bordercolor black -border 8 "$WORK/$head.png"
  echo "wrote $WORK/$head.png"
done

echo
echo "Check in $WORK/vga0.png that it says 'mirrored displays: 2' and lists both heads,"
echo "and that $WORK/vga1.png shows the same content -- that is the mirror working."
