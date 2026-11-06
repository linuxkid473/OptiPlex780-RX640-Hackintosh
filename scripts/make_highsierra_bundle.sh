#!/bin/bash
# Assemble the folder you copy to the OptiPlex (see scripts/highsierra/BUNDLE_README.txt).
# Usage: scripts/make_highsierra_bundle.sh ~/Downloads/HighSierra-GPU-Setup
set -euo pipefail
R="$(cd "$(dirname "$0")/.." && pwd)"; O="${1:?usage: $0 <output folder>}"
rm -rf "$O"; mkdir -p "$O/LegacyBoot"
cp "$R/scripts/make_injector.py" "$O/"
for f in install_injector.sh apply_stage2.sh apply_codec.sh install_to_internal.sh remove_injector_from_installer.sh diag_sse42.sh ssetest.c vtcheck.c hwdecode.m; do cp "$R/scripts/highsierra/$f" "$O/"; done
cp "$R/scripts/highsierra/BUNDLE_README.txt" "$O/README.txt"
cp "$R/EFI-HighSierra/EFI/OC/config-accel.plist" "$R/EFI-HighSierra/EFI/OC/ACPI/SSDT-RX640-CONNECTORS.aml" "$R/EFI-HighSierra/EFI/OC/ACPI/SSDT-RX640-CODEC.aml" "$O/"
cp -R "$R/EFI-HighSierra/EFI/OC/Kexts/AAAMouSSE.kext" "$O/"
cp "$R/extras/LegacyBoot/"{boot0,boot1f32,bootX64} "$O/LegacyBoot/"
# High Sierra has no compiler: prebuild the small test tools for it (needs clang on this Mac)
if command -v clang >/dev/null; then
  clang -arch x86_64 -mmacosx-version-min=10.13 -o "$O/ssetest" "$O/ssetest.c"
  clang -arch x86_64 -mmacosx-version-min=10.13 -fno-modules -fno-autolink -framework VideoToolbox -framework CoreFoundation -o "$O/vtcheck" "$O/vtcheck.c"
  clang -arch x86_64 -mmacosx-version-min=10.13 -fno-modules -fno-autolink -ObjC -Wl,-dead_strip_dylibs -framework Foundation -framework AVFoundation -framework VideoToolbox -framework CoreMedia -framework CoreVideo -o "$O/hwdecode" "$O/hwdecode.m"
  install_name_tool -change @rpath/libswiftCoreMedia.dylib /System/Library/Frameworks/CoreMedia.framework/Versions/A/CoreMedia "$O/hwdecode"   # new SDK links a Swift overlay High Sierra lacks
  command -v ffmpeg >/dev/null && ffmpeg -loglevel error -y -f lavfi -i testsrc2=size=1920x1080:rate=30 -t 10 -c:v libx264 -preset veryfast -profile:v high -pix_fmt yuv420p "$O/h264-1080p30.mp4" || true
else echo "WARNING: no clang - ssetest/vtcheck not built"; fi
chmod +x "$O"/*.sh "$O/make_injector.py"
echo "bundle ready: $O"
