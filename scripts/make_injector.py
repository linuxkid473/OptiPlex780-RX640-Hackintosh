#!/usr/bin/env python3
"""Build a codeless RX640Injector.kext from the running system's own AMD kext personalities.

Copies every IOKit personality whose IOPCIMatch contains the Baffin id (0x67FF1002) from
AMD9500Controller, AMDRadeonX4000 and AMDRadeonX4000HWServices, and retargets it to the
RX 640's real id (0x69871002). Install the result into /Library/Extensions (NOT OpenCore) so it
loads from the Auxiliary Kernel Collection, after Lilu/WhateverGreen are active.

Works with Python 2.7 (High Sierra's /usr/bin/python) and Python 3.

Usage (on the target Mac):
    python make_injector.py [--ext-dir /System/Library/Extensions] [--out RX640Injector.kext]
"""
from __future__ import print_function
import argparse, copy, os, plistlib, sys


def load(path):
    with open(path, "rb") as f:
        return plistlib.load(f) if hasattr(plistlib, "load") else plistlib.readPlist(path)


def dump(obj, path):
    if hasattr(plistlib, "dump"):
        with open(path, "wb") as f:
            plistlib.dump(obj, f)
    else:
        plistlib.writePlist(obj, path)


SOURCE_KEXTS = ("AMD9500Controller", "AMDRadeonX4000", "AMDRadeonX4000HWServices")
SPOOF_MATCH = "0x67FF1002"
REAL_MATCH = "0x69871002"

ap = argparse.ArgumentParser()
ap.add_argument("--ext-dir", default="/System/Library/Extensions")
ap.add_argument("--out", default="RX640Injector.kext")
args = ap.parse_args()

personalities = {}
for name in SOURCE_KEXTS:
    pl = load(os.path.join(args.ext_dir, name + ".kext/Contents/Info.plist"))
    for pname, pers in pl["IOKitPersonalities"].items():
        if SPOOF_MATCH in pers.get("IOPCIMatch", ""):
            p = copy.deepcopy(pers)
            p["IOPCIMatch"] = REAL_MATCH
            p.setdefault("CFBundleIdentifier", pl["CFBundleIdentifier"])
            personalities["{0} - {1} (RX 640)".format(name, pname)] = p
            print("{0}: {1} -> {2}".format(name, pname, p.get("IOClass")))

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
if not os.path.isdir(os.path.join(args.out, "Contents")):
    os.makedirs(os.path.join(args.out, "Contents"))
if not personalities:
    sys.exit("No 0x67FF1002 personalities found in " + args.ext_dir + " - this macOS has no Baffin support to retarget")
dump(info, os.path.join(args.out, "Contents/Info.plist"))
print("wrote {0} with {1} personalities".format(args.out, len(personalities)))
