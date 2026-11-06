#!/bin/bash
# Make the OptiPlex 780 boot OpenCore from its INTERNAL disk (no USB needed).
# Run ON THE OPTIPLEX, booted into the installed High Sierra (via the USB), in Terminal as a normal user (it uses sudo).
# It copies the EFI folder + `boot` from the USB's OPENCORE partition to the internal disk's EFI partition,
# writes OpenDuet's boot1f32 to that partition's boot sector and boot0 to the MBR boot code (partition table untouched).
# Needs LegacyBoot/{boot0,boot1f32,bootX64} next to this script. Override the disk with DISK=disk0 if detection is wrong.
# !!! Never mark the GPT protective-MBR entry active (playbook §9) - this script leaves the partition table alone.
set -eu
trap 'echo "FAILED at line $LINENO: $BASH_COMMAND"' ERR
HERE="$(cd "$(dirname "$0")" && pwd)"
LB="$HERE/LegacyBoot"
for f in boot0 boot1f32 bootX64; do [ -s "$LB/$f" ] || { echo "ABORT: $LB/$f missing"; exit 1; }; done
val() { diskutil info "$1" | sed -n "s|^ *$2: *||p" | head -1 || true; }
WORK="$(mktemp -d)"

# ---- find the internal disk (the one High Sierra is running from) and the USB OPENCORE partition ----
DISK="${DISK:-$(val / 'Part of Whole')}"
[ -n "$DISK" ] || { echo "ABORT: cannot detect the boot disk; run with DISK=disk0"; exit 1; }
[ "$(val "$DISK" 'Device Location')" = "Internal" ] || { echo "ABORT: $DISK is not internal (booted from the USB's installer?). Use DISK=diskN"; exit 1; }
diskutil info "$DISK" | grep -q GUID_partition_scheme || { echo "ABORT: $DISK is not GPT"; exit 1; }
ESP="${DISK}s1"
diskutil info "$ESP" | grep -q "EFI" || { echo "ABORT: $ESP is not the EFI partition"; exit 1; }
diskutil info "$ESP" | grep -q "MS-DOS FAT32" || { echo "ABORT: $ESP is not FAT32"; exit 1; }
OCID="$(diskutil list | awk '/ OPENCORE / {print $NF}' | head -1)"
[ -n "$OCID" ] || { echo "ABORT: USB 'OPENCORE' partition not found (is the stick plugged in?)"; exit 1; }
[ "$(val "$OCID" 'Part of Whole')" != "$DISK" ] || { echo "ABORT: OPENCORE is on the internal disk already"; exit 1; }
sudo diskutil mount "$OCID" >/dev/null 2>&1 || true
UM="$(val "$OCID" 'Mount Point')"
[ -f "$UM/EFI/OC/config.plist" ] || { echo "ABORT: no EFI/OC/config.plist on $OCID"; exit 1; }

echo "Internal disk : $DISK  ($(val "$DISK" 'Device / Media Name'), $(val "$DISK" 'Disk Size' | cut -d'(' -f1))"
echo "EFI partition : $ESP  <- will be overwritten with the EFI from $UM"
echo "MBR boot code : $DISK  (boot0 written; partition table kept)"
printf "Type YES to continue: "; read -r A; [ "$A" = "YES" ] || { echo "Cancelled."; exit 1; }

TS="$(date +%Y%m%d-%H%M%S)"; BK="$HOME/ESP-backup-$TS"; mkdir -p "$BK"
echo "==> [1/5] Backing up sector 0 + internal EFI partition to $BK"
sudo -v
sudo dd if=/dev/r$DISK of="$BK/disk-sector0.bin" bs=512 count=1
sudo diskutil mount "$ESP" >/dev/null 2>&1 || true
EM="$(val "$ESP" 'Mount Point')"; [ -n "$EM" ] || { echo "ABORT: could not mount $ESP"; exit 1; }
(cd "$EM" && sudo tar -cf "$BK/esp-contents.tar" .) || echo "   (tar backup of the EFI partition had warnings - continuing)"

echo "==> [2/5] Copying EFI + boot to $EM"
sudo rm -rf "$EM/EFI"
sudo cp -R "$UM/EFI" "$EM/EFI"
sudo cp "$LB/bootX64" "$EM/boot"
sudo find "$EM" -name '._*' -delete
diff -rq "$UM/EFI" "$EM/EFI" && echo "   EFI copy verified identical"
cmp "$LB/bootX64" "$EM/boot" && echo "   boot file verified"
sync; sudo diskutil unmount force "$ESP" >/dev/null

echo "==> [3/5] Writing boot1f32 to the $ESP boot sector (keeping its BPB)"
sudo dd if=/dev/r$ESP of="$BK/esp-pbr-orig.bin" bs=512 count=1
cp "$LB/boot1f32" "$WORK/newbs"
dd if="$BK/esp-pbr-orig.bin" of="$WORK/newbs" skip=3 seek=3 bs=1 count=87 conv=notrunc 2>/dev/null
sudo dd if="$WORK/newbs" of=/dev/r$ESP bs=512 count=1
sudo dd if=/dev/r$ESP bs=512 count=1 2>/dev/null | cmp - "$WORK/newbs" && echo "   boot sector verified"

echo "==> [4/5] Writing boot0 to $DISK MBR boot code"
sudo fdisk -uy -f "$LB/boot0" /dev/r$DISK 2>&1 | grep -v '^$' || true   # "could not be accessed exclusively" is harmless
sudo dd if=/dev/r$DISK of="$WORK/mbr_now.bin" bs=512 count=1
cmp <(head -c 440 "$WORK/mbr_now.bin") <(head -c 440 "$LB/boot0") && echo "   MBR boot code verified"
cmp <(tail -c 66 "$WORK/mbr_now.bin") <(tail -c 66 "$BK/disk-sector0.bin") && echo "   partition table + boot flag unchanged"

echo "==> [5/5] Final check"
sudo diskutil mount "$ESP" >/dev/null 2>&1 || true
EM="$(val "$ESP" 'Mount Point')"; ls "$EM" "$EM/EFI/OC"; sudo diskutil unmount "$ESP" >/dev/null
sudo chown -R "$(id -un)" "$BK"
diskutil list "$DISK"
echo
echo "DONE. Backup in $BK"
echo "Shut down, UNPLUG the USB, and boot. If the BIOS says BOOT FAIL: set the internal HDD first in the boot order;"
echo "if it still fails, boot from the USB again and tell me what it shows."
