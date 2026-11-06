#!/bin/bash
# Builds a legacy-BIOS (OpenDuet) OpenCore + macOS High Sierra (10.13.6) installer USB for the OptiPlex 780.
# SRC_VOL = a createinstallmedia volume made from "Install macOS High Sierra.app" (see HIGH_SIERRA.md for the expired-certificate workaround).
# SRC may also be a .dmg containing that volume (cloned block-level, works on hosts that cannot mount HFS+).
# Usage: DISK=diskN USB_NAME="SanDisk 3.2Gen1" USB_BYTES=30784094208 ./scripts/make_usb_highsierra.sh "/Volumes/Install macOS High Sierra"
#    or: ... ./scripts/make_usb_highsierra.sh ~/Downloads/"High Sierra 10.13.dmg"
# !!! ERASES the target disk. Check `diskutil list` and set DISK / USB_NAME / USB_BYTES to YOUR stick first.
set -euo pipefail

DISK="${DISK:?set DISK=diskN (your USB stick)}"
USB_NAME="${USB_NAME:?set USB_NAME to the stick Media Name from diskutil info}"
USB_BYTES="${USB_BYTES:?set USB_BYTES to the stick size in bytes from diskutil info}"
HERE="$(cd "$(dirname "$0")/.." && pwd)"   # repo root
LEGACY="$HERE/extras/LegacyBoot"
EFI_SRC="$HERE/EFI-HighSierra/EFI"
EFI_BACKUP="$HERE/EFI-Mojave-stable-vesa"
SRC_VOL="$1"
WORK="$(mktemp -d)"

# --- Safety: only ever touch the 30.8 GB SanDisk external stick ---
INFO="$(diskutil info $DISK)"
echo "$INFO" | grep -q "$USB_NAME"                  || { echo "ABORT: $DISK is not $USB_NAME"; exit 1; }
echo "$INFO" | grep -q "$USB_BYTES Bytes"           || { echo "ABORT: $DISK size mismatch"; exit 1; }
echo "$INFO" | grep -Eq "Device Location: +External" || { echo "ABORT: $DISK is not external"; exit 1; }
if [[ "$SRC_VOL" == *.dmg ]]; then
  [ -f "$SRC_VOL" ] || { echo "ABORT: $SRC_VOL not found"; exit 1; }
else
  [ -d "$SRC_VOL/Install macOS High Sierra.app" ] || { echo "ABORT: High Sierra installer not found at $SRC_VOL"; exit 1; }
fi
[ -f "$EFI_SRC/OC/config.plist" ]                  || { echo "ABORT: $EFI_SRC missing"; exit 1; }

echo "==> [1/6] Partitioning $DISK (MBR: FAT32 OPENCORE + HFS+ installer)"
diskutil unmountDisk force $DISK
diskutil partitionDisk $DISK MBR FAT32 OPENCORE 300M JHFS+ INSTALLER R

echo "==> [2/6] Cloning High Sierra installer onto ${DISK}s2 (takes a while)"
if [[ "$SRC_VOL" == *.dmg ]]; then
  ATTACH="$(hdiutil attach -readonly -nobrowse -nomount -noverify "$SRC_VOL")"
  SRC_DEV="$(echo "$ATTACH" | awk '/Apple_HFS|Apple_APFS/ {print $1; exit}')"
  [ -n "$SRC_DEV" ] || { echo "ABORT: no HFS partition in $SRC_VOL"; exit 1; }
  diskutil unmount force ${DISK}s2 2>/dev/null || true
  sudo asr restore --source "$SRC_DEV" --target /dev/${DISK}s2 --erase --noprompt --noverify
  hdiutil detach "$(echo "$ATTACH" | awk 'NR==1{print $1}')" || true
  diskutil mount ${DISK}s2 || true
elif ! sudo asr restore --source "$SRC_VOL" --target /Volumes/INSTALLER --erase --noprompt; then
  echo "asr failed, falling back to file copy"
  diskutil eraseVolume JHFS+ "Install macOS High Sierra" ${DISK}s2
  sudo ditto "$SRC_VOL" "/Volumes/Install macOS High Sierra"
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

echo "==> [6/6] Copying OpenCore EFI-HighSierra (+ Mojave EFI backup) + DuetPkg 'boot' file"
diskutil mount ${DISK}s1
MP="$(diskutil info ${DISK}s1 | sed -n 's/.*Mount Point: *//p')"
cp "$LEGACY/bootX64" "$MP/boot"
cp -R "$EFI_SRC" "$MP/EFI"
mkdir -p "$MP/Backup"
cp -R "$EFI_BACKUP" "$MP/Backup/EFI-Mojave-stable"
# Fill the repo's SMBIOS placeholders with random stand-ins on the USB copy only (valid for booting/installing;
# generate real values with macserial for iMessage/App Store and put them in the configs).
python3 - "$MP/EFI/OC" <<'PY'
import plistlib, random, string, sys, uuid, os
d = sys.argv[1]
for n in ("config.plist", "config-accel.plist"):
    p = os.path.join(d, n)
    if not os.path.exists(p):
        continue
    c = plistlib.load(open(p, "rb")); g = c["PlatformInfo"]["Generic"]
    al = string.ascii_uppercase + string.digits
    if g["SystemSerialNumber"].startswith("REPLACE"): g["SystemSerialNumber"] = "C02" + "".join(random.choice(al) for _ in range(9))
    if g["MLB"].startswith("REPLACE"): g["MLB"] = "C02" + "".join(random.choice(al) for _ in range(14))
    if g["SystemUUID"] == "00000000-0000-0000-0000-000000000000": g["SystemUUID"] = str(uuid.uuid4()).upper()
    if g["ROM"] == bytes(6): g["ROM"] = bytes([0x00] + [random.randrange(256) for _ in range(5)])
    plistlib.dump(c, open(p, "wb"), sort_keys=True)
    print("SMBIOS stand-ins written to", p)
PY
dot_clean -m "$MP" 2>/dev/null || true
find "$MP" -name '._*' -delete
sync

echo
diskutil list $DISK
echo "DONE - High Sierra USB is ready."
