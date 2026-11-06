#!/bin/bash
# Run in the High Sierra INSTALLER's Terminal (boot the USB, pick "Install macOS High Sierra", Utilities > Terminal):
#     bash /Volumes/<usb>/remove_injector_from_installer.sh  [volume name of the installed system, default: Macintosh\ HD]
# Use when the installed system hangs on the text console / WindowServer crash-loops after installing RX640Injector:
# removes the injector from /Library/Extensions and rebuilds the kext caches (kextcache -i bakes /Library/Extensions
# personalities into the prelinkedkernel, so they stay active even in safe mode until the cache is rebuilt).
HD="/Volumes/${1:-Macintosh HD}"
[ -d "$HD/System/Library" ] || { echo "$HD not found. Volumes:"; ls /Volumes; exit 1; }
rm -rf "$HD/Library/Extensions/RX640Injector.kext"
touch "$HD/Library/Extensions" "$HD/System/Library/Extensions"
echo "rebuilding kext caches on $HD (several minutes - do not interrupt)"
kextcache -i "$HD"
echo "injector references left in prelinkedkernel (0 = clean):"
grep -a -c "com.optiplex780.RX640Injector" "$HD/System/Library/PrelinkedKernels/prelinkedkernel"
echo DONE
