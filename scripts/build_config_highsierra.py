#!/usr/bin/env python3
"""Generate the two OpenCore configs for macOS High Sierra (10.13.6) on the OptiPlex 780 + RX 640.

Starts from the Mojave "stable-vesa" config (validated with OpenCore 1.0.7's ocvalidate, known to boot on this
OptiPlex 780), so no OpenCore Sample.plist is needed.  Writes into EFI-HighSierra/EFI/OC/:

  config.plist        STAGE 1 - safe, unaccelerated VESA display (-radvesa).  Use for the installer and first boots.
  config-accel.plist  STAGE 2 - GPU acceleration (verified: Metal, 4 GB, 1080p60):
                        * real device-id 0x6987 (no spoof) + RX640Injector in /Library/Extensions (see HIGH_SIERRA.md)
                        * SSDT-RX640-CONNECTORS (DisplayPort first -> framebuffer 0)
                        * AAAMouSSE (PATCHED for High Sierra, see scripts/patch_mousse_highsierra.py) loaded first
                        * no -radvesa

Common to both:
  * csr-active-config 0x67 (allow the unsigned injector into the kext cache - with SIP on, kextcache says
    "Untrusted kexts are not allowed")
  * SMBIOS iMacPro1,1 (same serial for both stages; SMBIOS=iMac10,1 gives native Penryn power management, untested here)
  * Mojave+/Monterey-only items removed (telemetrap, GPU-spoof SSDT, ASPP-Override, IOHID patch ...)

Usage: python3 scripts/build_config_highsierra.py
"""
import copy
import os
import plistlib

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
BASE = os.path.join(REPO, "EFI-Mojave-stable-vesa", "OC", "config.plist")
OUTDIR = os.path.join(REPO, "EFI-HighSierra", "EFI", "OC")
APPLE = "7C436110-AB2A-4BBB-A880-FE41995C9F82"

with open(BASE, "rb") as f:
    c = plistlib.load(f)

# ---------- ACPI: only the patched Dell DSDT ----------
c["ACPI"]["Add"] = [{"Comment": "Patched Dell OptiPlex 780 DSDT", "Enabled": True, "Path": "DSDT.aml"}]

# ---------- DeviceProperties: leave the RX 640 alone (real 0x6987) ----------
c["DeviceProperties"]["Add"] = {}
c["DeviceProperties"]["Delete"] = {}

# ---------- Kernel ----------
c["Kernel"]["Add"] = [k for k in c["Kernel"]["Add"] if k["BundlePath"] != "telemetrap.kext"]  # Mojave+ only
c["Kernel"]["Add"].insert(0, {
    "Arch": "x86_64", "BundlePath": "AAAMouSSE.kext", "Enabled": False, "ExecutablePath": "Contents/MacOS/MouSSE",
    "PlistPath": "Contents/Info.plist", "MinKernel": "", "MaxKernel": "",
    "Comment": "SSE4.2 (pcmpgtq) emulation, patched to hook hndl_alltraps on xnu-4570 - stage 2 only"})

# ---------- NVRAM / debug ----------
nv = c["NVRAM"]["Add"][APPLE]
nv["boot-args"] = "-v keepsyms=1 debug=0x100 alcid=11 agdpmod=pikera -radvesa"   # -radvesa: AMD acceleration off
nv["csr-active-config"] = bytes.fromhex("67000000")
# NOTE: OpenCore file logging (Target 67) only produced empty files with OpenDuet; keep it off.
c["Misc"]["Debug"].update(Target=3, DisplayLevel=0x80000042)

# ---------- PlatformInfo (serial/MLB/UUID/ROM stay placeholders: use macserial, see HIGH_SIERRA.md) ----------
c["PlatformInfo"]["Generic"]["SystemProductName"] = os.environ.get("SMBIOS", "iMacPro1,1")


def write(cfg, name):
    path = os.path.join(OUTDIR, name)
    with open(path, "wb") as f:
        plistlib.dump(cfg, f, sort_keys=True)
    print("wrote %s  (SMBIOS %s)" % (path, cfg["PlatformInfo"]["Generic"]["SystemProductName"]))


write(c, "config.plist")

# ---------- Stage 2: GPU acceleration ----------
a = copy.deepcopy(c)
a["ACPI"]["Add"].append({"Comment": "RX 640: DisplayPort first (framebuffer 0); real device-id kept", "Enabled": True,
                         "Path": "SSDT-RX640-CONNECTORS.aml"})
for k in a["Kernel"]["Add"]:
    if k["BundlePath"] == "AAAMouSSE.kext":
        k["Enabled"] = True
a["Kernel"]["Add"].sort(key=lambda k: k["BundlePath"] != "AAAMouSSE.kext")   # MouSSE must load first
a["NVRAM"]["Add"][APPLE]["boot-args"] = "-v keepsyms=1 debug=0x100 alcid=11 agdpmod=pikera"   # drop -radvesa
write(a, "config-accel.plist")
