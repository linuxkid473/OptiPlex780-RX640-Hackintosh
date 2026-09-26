#!/bin/bash
# Builds a legacy-BIOS (OpenDuet) OpenCore + Mojave installer USB for the OptiPlex 780.
# NOTE: original one-off script used to build the Mojave USB (hardcoded disk11 / paths). See make_usb_monterey.sh for the parameterised version.
set -euo pipefail

DISK=disk11
HERE="$(cd "$(dirname "$0")" && pwd)"
SRC_VOL="/Volumes/Install macOS Mojave"
WORK="$(mktemp -d)"

# --- Safety: only ever touch the 30.8 GB SanDisk external stick ---
INFO="$(diskutil info $DISK)"
echo "$INFO" | grep -q "SanDisk 3.2Gen1"            || { echo "ABORT: $DISK is not the SanDisk stick"; exit 1; }
echo "$INFO" | grep -q "30784094208 Bytes"          || { echo "ABORT: $DISK size mismatch"; exit 1; }
echo "$INFO" | grep -Eq "Device Location: +External" || { echo "ABORT: $DISK is not external"; exit 1; }
[ -d "$SRC_VOL/Install macOS Mojave.app" ]          || { echo "ABORT: Mojave image not mounted"; exit 1; }

echo "==> [1/6] Partitioning $DISK (MBR: FAT32 OPENCORE + HFS+ installer)"
diskutil unmountDisk force $DISK
diskutil partitionDisk $DISK MBR FAT32 OPENCORE 300M JHFS+ INSTALLER R

echo "==> [2/6] Cloning Mojave installer onto ${DISK}s2 (takes a while)"
if ! sudo asr restore --source "$SRC_VOL" --target /Volumes/INSTALLER --erase --noprompt; then
  echo "asr failed, falling back to file copy"
  diskutil eraseVolume JHFS+ "Install macOS Mojave" ${DISK}s2
  sudo ditto "$SRC_VOL" "/Volumes/Install macOS Mojave"
fi

echo "==> [3/6] Writing boot0 to the MBR"
sudo fdisk -uy -f "$HERE/LegacyBoot/boot0" /dev/r$DISK

echo "==> [4/6] Writing boot1f32 to the OPENCORE partition boot sector"
diskutil unmount force ${DISK}s1
sudo dd if=/dev/r${DISK}s1 count=1 of="$WORK/origbs"
cp "$HERE/LegacyBoot/boot1f32" "$WORK/newbs"
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

echo "==> [6/6] Copying OpenCore EFI + DuetPkg 'boot' file"
diskutil mount ${DISK}s1
MP="$(diskutil info ${DISK}s1 | sed -n 's/.*Mount Point: *//p')"
cp "$HERE/LegacyBoot/bootX64" "$MP/boot"
cp -R "$HERE/EFI" "$MP/"
dot_clean -m "$MP" 2>/dev/null || true
find "$MP" -name '._*' -delete
sync

echo
diskutil list $DISK
echo "DONE - USB is ready."
