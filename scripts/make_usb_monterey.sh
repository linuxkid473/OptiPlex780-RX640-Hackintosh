#!/bin/bash
# Builds a legacy-BIOS (OpenDuet) OpenCore + macOS Monterey installer USB for the OptiPlex 780.
# Usage: DISK=diskN USB_NAME="SanDisk 3.2Gen1" USB_BYTES=30784094208 ./scripts/make_usb_monterey.sh "/Volumes/Install macOS Monterey"
# !!! ERASES the target disk. Check `diskutil list` and set DISK / USB_NAME / USB_BYTES to YOUR stick first.
set -euo pipefail

DISK="${DISK:?set DISK=diskN (your USB stick)}"
USB_NAME="${USB_NAME:?set USB_NAME to the stick Media Name from diskutil info}"
USB_BYTES="${USB_BYTES:?set USB_BYTES to the stick size in bytes from diskutil info}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"   # repo root
LEGACY="$HERE/extras/LegacyBoot"
EFI_SRC="$HERE/EFI-USB-working/EFI"
EFI_BACKUP="$HERE/EFI-Mojave-stable-vesa"
SRC_VOL="$1"
WORK="$(mktemp -d)"

# --- Safety: only ever touch the 30.8 GB SanDisk external stick ---
INFO="$(diskutil info $DISK)"
echo "$INFO" | grep -q "$USB_NAME"                  || { echo "ABORT: $DISK is not $USB_NAME"; exit 1; }
echo "$INFO" | grep -q "$USB_BYTES Bytes"           || { echo "ABORT: $DISK size mismatch"; exit 1; }
echo "$INFO" | grep -Eq "Device Location: +External" || { echo "ABORT: $DISK is not external"; exit 1; }
[ -d "$SRC_VOL/Install macOS Monterey.app" ]        || { echo "ABORT: Monterey installer not found at $SRC_VOL"; exit 1; }
[ -f "$EFI_SRC/OC/config.plist" ]                  || { echo "ABORT: $EFI_SRC missing"; exit 1; }

echo "==> [1/6] Partitioning $DISK (MBR: FAT32 OPENCORE + HFS+ installer)"
diskutil unmountDisk force $DISK
diskutil partitionDisk $DISK MBR FAT32 OPENCORE 300M JHFS+ INSTALLER R

echo "==> [2/6] Cloning Monterey installer onto ${DISK}s2 (takes a while)"
if ! sudo asr restore --source "$SRC_VOL" --target /Volumes/INSTALLER --erase --noprompt; then
  echo "asr failed, falling back to file copy"
  diskutil eraseVolume JHFS+ "Install macOS Monterey" ${DISK}s2
  sudo ditto "$SRC_VOL" "/Volumes/Install macOS Monterey"
fi

echo "==> [3/6] Writing boot0 to the MBR"
sudo fdisk -uy -f "$LEGACY/boot0" /dev/r$DISK

echo "==> [4/6] Writing boot1f32 to the OPENCORE partition boot sector"
diskutil unmount force ${DISK}s1
sudo dd if=/dev/r${DISK}s1 count=1 of="$WORK/origbs"
cp "$LEGACY/boot1f32" "$WORK/newbs"
dd if="$WORK/origbs" of="$WORK/newbs" skip=3 seek=3 bs=1 count=87 conv=notrunc
dd if=/dev/random of="$WORK/newbs" skip=496 seek=496 bs=1 count=14 conv=notrunc
sudo dd if="$WORK/newbs" of=/dev/r${DISK}s1

echo "==> [5/6] Marking partition 1 active"
sudo fdisk -e /dev/r$DISK <<'EOF'
p
f 1
w
y
q
EOF

echo "==> [6/6] Copying OpenCore EFI-Monterey (+ Mojave EFI backup) + DuetPkg 'boot' file"
diskutil mount ${DISK}s1
MP="$(diskutil info ${DISK}s1 | sed -n 's/.*Mount Point: *//p')"
cp "$LEGACY/bootX64" "$MP/boot"
cp -R "$EFI_SRC" "$MP/EFI"
mkdir -p "$MP/Backup"
cp -R "$EFI_BACKUP" "$MP/Backup/EFI-Mojave-stable"
dot_clean -m "$MP" 2>/dev/null || true
find "$MP" -name '._*' -delete
sync

echo
diskutil list $DISK
echo "DONE - Monterey USB is ready."
