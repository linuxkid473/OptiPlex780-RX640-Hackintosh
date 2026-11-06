#!/bin/bash
# Run ON the OptiPlex (High Sierra) to enable GPU H.264/HEVC hardware decode (the Monterey "-radcodec" recipe).
# Usage: ./apply_codec.sh /Volumes/OPENCORE      (the mounted EFI partition you boot from)
# - backs up EFI/OC/config.plist -> config-before-codec.plist
# - ACPI: disables SSDT-RX640-CONNECTORS, enables SSDT-RX640-CODEC (same connector reorder + device-id PROPERTY 0x67FF + no-gfx-spoof,
#         so the video engine sees a Baffin PID while CAIL still reads the real 0x6987)
# - boot-args: adds -radcodec
# Revert: cp config-before-codec.plist config.plist
set -e
EFI="${1:?usage: $0 /Volumes/<EFI partition mount>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
OC="$EFI/EFI/OC"
[ -f "$OC/config.plist" ] || { echo "No $OC/config.plist - wrong volume?"; exit 1; }
[ -f "$HERE/SSDT-RX640-CODEC.aml" ] || { echo "SSDT-RX640-CODEC.aml missing next to this script"; exit 1; }
[ -f "$OC/config-before-codec.plist" ] || cp "$OC/config.plist" "$OC/config-before-codec.plist"
mkdir -p "$OC/ACPI"; cp "$HERE/SSDT-RX640-CODEC.aml" "$OC/ACPI/"
python - "$OC/config.plist" <<'PY'
import plistlib, sys
p = sys.argv[1]
c = plistlib.load(open(p, "rb")) if hasattr(plistlib, "load") else plistlib.readPlist(p)
add = [a for a in c["ACPI"]["Add"] if a["Path"] not in ("SSDT-RX640-CONNECTORS.aml", "SSDT-RX640-CODEC.aml")]
add.append({"Comment": "RX 640: connector reorder + device-id property 0x67FF + no-gfx-spoof (video codec)", "Enabled": True, "Path": "SSDT-RX640-CODEC.aml"})
c["ACPI"]["Add"] = add
nv = c["NVRAM"]["Add"]["7C436110-AB2A-4BBB-A880-FE41995C9F82"]
if "-radcodec" not in nv["boot-args"].split():
    nv["boot-args"] += " -radcodec"
if hasattr(plistlib, "dump"):
    plistlib.dump(c, open(p, "wb"))
else:
    plistlib.writePlist(c, p)
print("ACPI:", [a["Path"] for a in c["ACPI"]["Add"] if a["Enabled"]]); print("boot-args:", nv["boot-args"])
PY
sync
echo "Done. Reboot, then run ./vtcheck (H.264 hardware decode should say YES). Revert: cp \"$OC/config-before-codec.plist\" \"$OC/config.plist\""
