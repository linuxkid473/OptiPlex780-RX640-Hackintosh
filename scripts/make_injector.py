#!/usr/bin/env python3
"""Build a codeless RX640Injector.kext from the running system's own AMD kext personalities.

Copies every IOKit personality whose IOPCIMatch contains the Baffin id (0x67FF1002) from
AMD9500Controller, AMDRadeonX4000 and AMDRadeonX4000HWServices, and retargets it to the
RX 640's real id (0x69871002). Install the result into /Library/Extensions (NOT OpenCore) so it
loads from the Auxiliary Kernel Collection, after Lilu/WhateverGreen are active.

Usage (on the target Mac):
    python3 make_injector.py [--ext-dir /System/Library/Extensions] [--out RX640Injector.kext]
"""
import argparse, copy, os, plistlib

SOURCE_KEXTS = ("AMD9500Controller", "AMDRadeonX4000", "AMDRadeonX4000HWServices")
SPOOF_MATCH = "0x67FF1002"
REAL_MATCH = "0x69871002"

ap = argparse.ArgumentParser()
ap.add_argument("--ext-dir", default="/System/Library/Extensions")
ap.add_argument("--out", default="RX640Injector.kext")
args = ap.parse_args()

personalities = {}
for name in SOURCE_KEXTS:
    pl = plistlib.load(open(os.path.join(args.ext_dir, f"{name}.kext/Contents/Info.plist"), "rb"))
    for pname, pers in pl["IOKitPersonalities"].items():
        if SPOOF_MATCH in pers.get("IOPCIMatch", ""):
            p = copy.deepcopy(pers)
            p["IOPCIMatch"] = REAL_MATCH
            p.setdefault("CFBundleIdentifier", pl["CFBundleIdentifier"])
            personalities[f"{name} - {pname} (RX 640)"] = p
            print(f"{name}: {pname} -> {p.get('IOClass')}")

info = {
    "CFBundleDevelopmentRegion": "English",
    "CFBundleIdentifier": "com.optiplex780.RX640Injector",
    "CFBundleInfoDictionaryVersion": "6.0",
    "CFBundleName": "RX640Injector",
    "CFBundlePackageType": "KEXT",
    "CFBundleShortVersionString": "2.0.0",
    "CFBundleSignature": "????",
    "CFBundleVersion": "2.0.0",
    "IOKitPersonalities": personalities,
}
os.makedirs(os.path.join(args.out, "Contents"), exist_ok=True)
plistlib.dump(info, open(os.path.join(args.out, "Contents/Info.plist"), "wb"))
print(f"wrote {args.out} with {len(personalities)} personalities")
