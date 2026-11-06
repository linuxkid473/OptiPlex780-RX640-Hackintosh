#!/bin/bash
# Run ON the High Sierra machine, after the injector is installed (see README.txt).
# Usage: ./apply_stage2.sh /Volumes/OPENCORE        (the mounted EFI/OpenCore FAT32 partition)
# - backs up EFI/OC/config.plist -> config-stage1.plist
# - installs config-accel.plist as config.plist, keeping the SMBIOS values from the current config
# - copies SSDT-RX640-CONNECTORS.aml and AAAMouSSE.kext if missing
set -e
EFI="${1:?usage: $0 /Volumes/<EFI partition mount>}"
HERE="$(cd "$(dirname "$0")" && pwd)"
OC="$EFI/EFI/OC"
[ -f "$OC/config.plist" ] || { echo "No $OC/config.plist - wrong volume?"; exit 1; }
[ -f "$HERE/config-accel.plist" ] || { echo "config-accel.plist missing next to this script"; exit 1; }
[ -d /Library/Extensions/RX640Injector.kext ] || echo "NOTE: injector not in /Library/Extensions yet - after rebooting with this config, run ./install_injector.sh, then reboot again."

[ -f "$OC/config-stage1.plist" ] || cp "$OC/config.plist" "$OC/config-stage1.plist"
mkdir -p "$OC/ACPI" "$OC/Kexts"
cp "$HERE/SSDT-RX640-CONNECTORS.aml" "$OC/ACPI/"
[ -d "$OC/Kexts/AAAMouSSE.kext" ] || cp -R "$HERE/AAAMouSSE.kext" "$OC/Kexts/"

# python2/3-compatible plist merge
python - "$OC/config-stage1.plist" "$HERE/config-accel.plist" "$OC/config.plist" <<'PY'
import plistlib, sys
def load(p):
    return plistlib.load(open(p, "rb")) if hasattr(plistlib, "load") else plistlib.readPlist(p)
def dump(o, p):
    if hasattr(plistlib, "dump"):
        plistlib.dump(o, open(p, "wb"))
    else:
        plistlib.writePlist(o, p)
old, new, out = load(sys.argv[1]), load(sys.argv[2]), sys.argv[3]
for k in ("SystemSerialNumber", "MLB", "SystemUUID", "ROM", "SystemProductName"):
    new["PlatformInfo"]["Generic"][k] = old["PlatformInfo"]["Generic"][k]
dump(new, out)
print("Wrote %s (SMBIOS kept from stage-1 config)" % out)
PY
sync
echo "Done. Reboot. To go back: cp \"$OC/config-stage1.plist\" \"$OC/config.plist\""
