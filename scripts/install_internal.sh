#!/bin/bash
# Install OpenDuet + OpenCore onto the OptiPlex 780 internal disk (GPT, FAT32 ESP) so it boots without the USB.
# Run ON THE TARGET with sudo, booted from the USB. Copies the USB's working EFI to the internal ESP and writes
# OpenDuet boot1f32 (ESP PBR) + boot0 (MBR boot code). Put boot0/boot1f32/bootX64 from extras/LegacyBoot in /tmp first.
# !!! DO NOT mark the GPT protective-MBR entry active: OpenDuet (EDK2 PartitionDxe) then no longer treats the disk
# as GPT -> APFS container invisible, internal boot fails ('BOOT FAIL') AND the USB picker loses macOS.
set -euo pipefail
DISK=${DISK:-disk0}; ESP=${ESP:-${DISK}s1}; USBP=${USBP:-disk2s1}; DISK_NAME=${DISK_NAME:-"WDC WD1600AAJS"}
diskutil info $DISK | grep -q "$DISK_NAME" || { echo "ABORT: $DISK is not $DISK_NAME"; exit 1; }
diskutil info $ESP | grep -q "MS-DOS FAT32"    || { echo "ABORT: $ESP not FAT32"; exit 1; }
diskutil info $USBP | grep -q "OPENCORE"       || { echo "ABORT: USB OPENCORE not at $USBP"; exit 1; }
for f in boot0 boot1f32 bootX64; do [ -s /tmp/$f ] || { echo "ABORT: /tmp/$f missing"; exit 1; }; done
TS=$(date +%Y%m%d-%H%M%S); BK=/Users/vihaannathan/ESP-backup-$TS; mkdir -p $BK

echo "==> [1/5] Backing up internal ESP and boot sectors to $BK"
dd if=/dev/r$DISK of=$BK/disk0-sector0.bin bs=512 count=1 2>/dev/null
diskutil mount $ESP >/dev/null
EM=$(diskutil info $ESP | sed -n 's/.*Mount Point: *//p')
(cd "$EM" && tar -cf $BK/esp-contents.tar . 2>/dev/null) || true
diskutil mount $USBP >/dev/null
UM=$(diskutil info $USBP | sed -n 's/.*Mount Point: *//p')

echo "==> [2/5] Copying working EFI + boot from USB ($UM) to internal ESP ($EM)"
rm -rf "$EM/EFI"
cp -R "$UM/EFI" "$EM/EFI"
cp /tmp/bootX64 "$EM/boot"
find "$EM" -name '._*' -delete
diff -rq "$UM/EFI" "$EM/EFI" && echo "   EFI copy verified identical"
cmp /tmp/bootX64 "$EM/boot" && echo "   boot file verified"
sync; diskutil unmount force $ESP >/dev/null

echo "==> [3/5] Writing boot1f32 to $ESP boot sector (keeping its BPB)"
dd if=/dev/r$ESP of=$BK/esp-pbr-orig.bin bs=512 count=1 2>/dev/null
cp /tmp/boot1f32 /tmp/newbs
dd if=$BK/esp-pbr-orig.bin of=/tmp/newbs skip=3 seek=3 bs=1 count=87 conv=notrunc 2>/dev/null
dd if=/tmp/newbs of=/dev/r$ESP bs=512 count=1 2>/dev/null
dd if=/dev/r$ESP bs=512 count=1 2>/dev/null | cmp - /tmp/newbs && echo "   ESP boot sector verified"

echo "==> [4/5] Writing boot0 to $DISK MBR boot code (partition table preserved)"
fdisk -uy -f /tmp/boot0 /dev/r$DISK 2>&1 | grep -v "^$" || true
dd if=/dev/r$DISK of=/tmp/mbr_now.bin bs=512 count=1 2>/dev/null   # raw devices need whole-sector reads
cmp <(head -c 440 /tmp/mbr_now.bin) <(head -c 440 /tmp/boot0) && echo "   MBR boot code verified"
cmp <(tail -c 66 /tmp/mbr_now.bin) <(tail -c 66 $BK/disk0-sector0.bin) && echo "   partition table + boot flag unchanged"

echo "==> [5/5] Final check"
diskutil mount $ESP >/dev/null; EM=$(diskutil info $ESP | sed -n 's/.*Mount Point: *//p')
ls "$EM" "$EM/EFI/OC"; diskutil unmount $ESP >/dev/null
diskutil list $DISK
echo "DONE - internal disk is set up. Backup in $BK"
