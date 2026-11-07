#!/bin/bash
# Puts the STOCK AAAMouSSE (hooks idt64_hndl_table0 slot +0x40) on the internal EFI.
# Needed for Apple's xnu-4570.71.82.6 (Security Update 2020-005), where hndl_alltraps moved from +0x28 back to +0x40.
# The patched kext (slot +0x28) is only right for the original 4570.71.2 kernel; it is backed up next to the EFI backup.
set -e
SRC="$HOME/mousse-stock/AAAMouSSE.kext"
[ -d "$SRC" ] || { echo "missing $SRC"; exit 1; }
sudo -v
DEV=$(diskutil list internal | awk '/EFI/ {print $NF; exit}')
echo "internal ESP: $DEV"
diskutil info "$DEV" | egrep "Volume Name|Mount Point" || true
[ -d /Volumes/EFI/EFI/OC ] || sudo diskutil mount "$DEV"
K=/Volumes/EFI/EFI/OC/Kexts
[ -d "$K/AAAMouSSE.kext" ] || { echo "ABORT: $K/AAAMouSSE.kext not found"; exit 1; }
B="$HOME/mousse-backup-$(date +%Y%m%d-%H%M%S)"; mkdir -p "$B"
cp -R "$K/AAAMouSSE.kext" "$B/AAAMouSSE-patched-slot28.kext"
cp /Volumes/EFI/EFI/OC/config.plist "$B/config.plist"
rm -rf "$K/AAAMouSSE.kext"
cp -R "$SRC" "$K/AAAMouSSE.kext"
sync
echo "done. backup: $B"
shasum "$K/AAAMouSSE.kext/Contents/MacOS/MouSSE" "$SRC/Contents/MacOS/MouSSE"
sudo diskutil unmount /Volumes/EFI >/dev/null 2>&1 || true
echo "Now reboot:  sudo reboot"
