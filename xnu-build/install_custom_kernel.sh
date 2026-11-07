#!/bin/bash
# Installs a self-built XNU (xnu-4570.71.2, RELEASE x86_64) as the boot kernel of macOS High Sierra and rebuilds the kext caches.
# SAFE BY DESIGN: Apple's kernel and PrelinkedKernels are backed up first, and a restore script is written next to the backup.
# Usage (on the OptiPlex, normal user; asks for sudo):  bash install_custom_kernel.sh /path/to/kernel
set -u
NEW="${1:?usage: $0 /path/to/kernel}"
K=/System/Library/Kernels
P=/System/Library/PrelinkedKernels
[ -f "$NEW" ] || { echo "ABORT: $NEW not found"; exit 1; }
file "$NEW" | grep -q "Mach-O 64-bit executable x86_64" || { echo "ABORT: $NEW is not an x86_64 kernel"; exit 1; }
strings -a "$NEW" | grep -q "Darwin Kernel Version 17.7.0" || { echo "ABORT: $NEW is not a 17.7.0 kernel"; exit 1; }
[ "$(sw_vers -productVersion)" = "10.13.6" ] || { echo "ABORT: not 10.13.6"; exit 1; }
sudo -v || exit 1

B="$HOME/kernel-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$B" || exit 1
echo "== 1/5 backing up Apple's kernel and prelinked kernels to $B"
sudo cp -p "$K/kernel" "$B/kernel.apple" || exit 1
sudo cp -Rp "$P" "$B/PrelinkedKernels.apple" || exit 1
sudo chown -R "$(id -un)" "$B"
echo "   apple kernel: $(stat -f %z "$B/kernel.apple") bytes, uuid $(otool -l "$B/kernel.apple" 2>/dev/null | awk '/LC_UUID/{f=1} f&&/uuid/{print $2; exit}')"

# restore script that works from a running system AND from the installer's Terminal (hackhd mounted)
cat > "$B/restore_apple_kernel.sh" <<EOF
#!/bin/bash
# Puts Apple's kernel and prelinked kernels back. Works from the installed system, or from the installer's Terminal:
#   bash /Volumes/hackhd/Users/$(id -un)/$(basename "$B")/restore_apple_kernel.sh /Volumes/hackhd
ROOT="\${1:-/}"; ROOT="\${ROOT%/}"
B="\$(cd "\$(dirname "\$0")" && pwd)"
sudo cp -p "\$B/kernel.apple" "\$ROOT/System/Library/Kernels/kernel" || exit 1
sudo rm -rf "\$ROOT/System/Library/PrelinkedKernels" && sudo cp -Rp "\$B/PrelinkedKernels.apple" "\$ROOT/System/Library/PrelinkedKernels" || exit 1
sudo touch "\$ROOT/System/Library/Extensions"
echo "Apple kernel restored on \$ROOT. Reboot. (Optionally run: sudo kextcache -i \$ROOT)"
EOF
chmod +x "$B/restore_apple_kernel.sh"

echo "== 2/5 installing the new kernel"
sudo cp "$NEW" "$K/kernel.xnubuild" || exit 1
sudo cp "$NEW" "$K/kernel" || { echo "FAILED to write $K/kernel (SIP?). Nothing else changed."; exit 1; }
sudo chown root:wheel "$K/kernel" "$K/kernel.xnubuild"; sudo chmod 755 "$K/kernel" "$K/kernel.xnubuild"
echo "   installed: $(stat -f %z "$K/kernel") bytes"

echo "== 3/5 rebuilding kext caches with the new kernel (several minutes, do not interrupt)"
sudo touch /System/Library/Extensions /Library/Extensions
sudo kextcache -i / 2>&1 | tail -15
RC=${PIPESTATUS[0]}

echo "== 4/5 verifying the prelinked kernel was rebuilt (it is compressed, so text search cannot verify it)"
if [ "$P/prelinkedkernel" -nt "$K/kernel.xnubuild" ] && [ "$(stat -f %z "$P/prelinkedkernel")" -gt 10000000 ]; then echo "   OK: prelinkedkernel was rebuilt after the new kernel was installed ($(stat -f %z "$P/prelinkedkernel") bytes). Final proof = sysctl kern.version after reboot."; else echo "   WARNING: prelinkedkernel was not rebuilt -> restoring Apple kernel"; "$B/restore_apple_kernel.sh"; exit 1; fi
ls -la "$P" | tail -4

echo "== 5/5 done"
echo "Backup + restore script: $B"
echo "To revert from the running system:      bash $B/restore_apple_kernel.sh"
echo "To revert if it will not boot: boot the USB installer > Utilities > Terminal:"
echo "   bash /Volumes/hackhd/Users/$(id -un)/$(basename "$B")/restore_apple_kernel.sh /Volumes/hackhd"
echo "Now reboot (sudo reboot) and watch for 'kernel.version' below after boot:  sysctl kern.version"
