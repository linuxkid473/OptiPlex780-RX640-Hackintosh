#!/bin/bash
# Assemble the folder you copy to the OptiPlex (see scripts/highsierra/BUNDLE_README.txt).
# Usage: scripts/make_highsierra_bundle.sh ~/Downloads/HighSierra-GPU-Setup
set -euo pipefail
R="$(cd "$(dirname "$0")/.." && pwd)"; O="${1:?usage: $0 <output folder>}"
rm -rf "$O"; mkdir -p "$O/LegacyBoot"
cp "$R/scripts/make_injector.py" "$O/"
for f in install_injector.sh apply_stage2.sh install_to_internal.sh remove_injector_from_installer.sh diag_sse42.sh ssetest.c; do cp "$R/scripts/highsierra/$f" "$O/"; done
cp "$R/scripts/highsierra/BUNDLE_README.txt" "$O/README.txt"
cp "$R/EFI-HighSierra/EFI/OC/config-accel.plist" "$R/EFI-HighSierra/EFI/OC/ACPI/SSDT-RX640-CONNECTORS.aml" "$O/"
cp -R "$R/EFI-HighSierra/EFI/OC/Kexts/AAAMouSSE.kext" "$O/"
cp "$R/extras/LegacyBoot/"{boot0,boot1f32,bootX64} "$O/LegacyBoot/"
chmod +x "$O"/*.sh "$O/make_injector.py"
echo "bundle ready: $O"
