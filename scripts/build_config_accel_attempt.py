import plistlib, sys

import os
# Folder that contains the unzipped OpenCore release as OpenCore-1.0.7-RELEASE/ (for Docs/Sample.plist)
S = os.environ.get("OC_WORKDIR", ".")
c = plistlib.load(open(f"{S}/OpenCore-1.0.7-RELEASE/Docs/Sample.plist", "rb"))

# ---------- ACPI: keep the patched Dell DSDT from the original EFI ----------
c["ACPI"]["Add"] = [
    {"Comment": "Patched Dell OptiPlex 780 DSDT", "Enabled": True, "Path": "DSDT.aml"},
    {"Comment": "RX 640 device-id spoof via _DSM on PCI0.PEG0.GFX0", "Enabled": True, "Path": "SSDT-GPU-SPOOF.aml"},
]
c["ACPI"]["Delete"] = []
c["ACPI"]["Patch"] = []

# ---------- Booter (Penryn / legacy BIOS via OpenDuet) ----------
c["Booter"]["MmioWhitelist"] = []
c["Booter"]["Patch"] = []
q = c["Booter"]["Quirks"]
for k in list(q):
    if isinstance(q[k], bool):
        q[k] = False
q.update(AvoidRuntimeDefrag=True, EnableSafeModeSlide=True, EnableWriteUnprotector=True,
         ProvideCustomSlide=True, SetupVirtualMap=True, RebuildAppleMemoryMap=False,
         SyncRuntimePermissions=False, ProvideMaxSlide=0, ResizeAppleGpuBars=-1,
         # Required with OpenDuet + SecureBootModel=Disabled, else boot.efi fails with 'Volume Corrupt'
         FixupAppleEfiImages=True)

# ---------- DeviceProperties: RX 640 (Lexa 0x6987) -> spoof as Baffin 0x67FF (backup for SSDT-GPU-SPOOF) ----------
# The patched Dell DSDT gives PCI0 _UID 0x04, so macOS matches this slot as PciRoot(0x4).
# Keep PciRoot(0x0) too in case the DSDT is ever dropped.
# Lexa 0x6987 is unsupported; Baffin 0x67FF (RX 550 640SP / RX 560) is what works in Mojave
_gpu = {"device-id": bytes.fromhex("FF670000"), "model": "AMD Radeon RX 640"}
c["DeviceProperties"]["Add"] = {
    "PciRoot(0x4)/Pci(0x1,0x0)/Pci(0x0,0x0)": dict(_gpu),
    "PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)": dict(_gpu),
}
c["DeviceProperties"]["Delete"] = {}

# ---------- Kernel ----------
def kext(path, exe, comment, enabled=True, minkernel=""):
    return {"Arch": "x86_64", "BundlePath": path, "Comment": comment, "Enabled": enabled,
            "ExecutablePath": exe, "MaxKernel": "", "MinKernel": minkernel,
            "PlistPath": "Contents/Info.plist"}

c["Kernel"]["Add"] = [
    kext("Lilu.kext", "Contents/MacOS/Lilu", "Patch engine"),
    kext("VirtualSMC.kext", "Contents/MacOS/VirtualSMC", "SMC emulator"),
    kext("WhateverGreen.kext", "Contents/MacOS/WhateverGreen", "AMD GPU fixes"),
    kext("AppleALC.kext", "Contents/MacOS/AppleALC", "Audio (AD1984A)"),
    kext("VoodooHDA.kext", "Contents/MacOS/VoodooHDA", "Audio fallback - enable only if AppleALC fails (and disable AppleALC)", enabled=False),
    kext("Intel82566MM.kext", "Contents/MacOS/Intel82566MM", "Onboard Intel 82567LM-3 Ethernet"),
    kext("SATA-unsupported.kext", "", "ICH10 AHCI"),
    kext("telemetrap.kext", "Contents/MacOS/telemetrap", "Penryn: stop com.apple.telemetry SSE4.2 crash (Mojave+)", minkernel="18.0.0"),
    kext("VoodooPS2Controller.kext", "Contents/MacOS/VoodooPS2Controller", "PS/2 controller"),
    kext("VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Keyboard.kext", "Contents/MacOS/VoodooPS2Keyboard", "PS/2 keyboard"),
    kext("VoodooPS2Controller.kext/Contents/PlugIns/VoodooPS2Mouse.kext", "Contents/MacOS/VoodooPS2Mouse", "PS/2 mouse"),
]
c["Kernel"]["Block"] = []
c["Kernel"]["Force"] = []
c["Kernel"]["Patch"] = []
kq = c["Kernel"]["Quirks"]
for k in list(kq):
    if isinstance(kq[k], bool):
        kq[k] = False
kq.update(AppleCpuPmCfgLock=True, DisableIoMapper=True, DisableLinkeditJettison=True,
          PanicNoKextDump=True, PowerTimeoutKernelPanic=True)
c["Kernel"]["Scheme"].update(FuzzyMatch=True, KernelArch="Auto", KernelCache="Auto")

# ---------- Misc ----------
c["Misc"]["Boot"].update(HideAuxiliary=False, PickerMode="Builtin", ShowPicker=True, Timeout=5,
                         PollAppleHotKeys=True, PickerAttributes=17)
c["Misc"]["Debug"].update(AppleDebug=True, ApplePanic=True, DisableWatchDog=True, Target=3)
c["Misc"]["Security"].update(AllowSetDefault=True, ScanPolicy=0, SecureBootModel="Disabled",
                             Vault="Optional", ExposeSensitiveData=6, BlacklistAppleUpdate=True)
c["Misc"]["Entries"] = []
c["Misc"]["BlessOverride"] = []
c["Misc"]["Tools"] = [{"Arguments": "", "Auxiliary": True, "Comment": "UEFI Shell", "Enabled": True,
                       "Flavour": "OpenShell:UEFIShell:Shell", "FullNvramAccess": False,
                       "Name": "UEFI Shell", "Path": "OpenShell.efi", "RealPath": False,
                       "TextMode": False}]

# ---------- NVRAM (emulated - legacy BIOS has no native NVRAM) ----------
apple = "7C436110-AB2A-4BBB-A880-FE41995C9F82"
c["NVRAM"]["Add"][apple] = {
    "boot-args": "-v keepsyms=1 debug=0x100 alcid=11 agdpmod=pikera -rad24",
    "csr-active-config": bytes.fromhex("00000000"),
    "prev-lang:kbd": b"en-US:0",
    "run-efi-updater": "No",
}
c["NVRAM"]["Delete"][apple] = ["boot-args", "csr-active-config", "prev-lang:kbd"]
c["NVRAM"].update(LegacyOverwrite=True, WriteFlash=True)

# ---------- PlatformInfo: iMacPro1,1 (dGPU-only, Mojave-supported) ----------
c["PlatformInfo"]["Generic"].update(
    SystemProductName="iMacPro1,1",
    SystemSerialNumber="REDACTED",
    MLB="REDACTED",
    SystemUUID="REDACTED",
    ROM=bytes(6),  # REPLACE with your ROM (6 bytes, e.g. NIC MAC)
    SpoofVendor=True,
)
c["PlatformInfo"].update(Automatic=True, UpdateSMBIOS=True, UpdateSMBIOSMode="Create",
                         UpdateDataHub=True, UpdateNVRAM=True)

# ---------- UEFI ----------
def drv(path, comment, load_early=False):
    return {"Arguments": "", "Comment": comment, "Enabled": True, "LoadEarly": load_early, "Path": path}

c["UEFI"]["Drivers"] = [
    drv("OpenVariableRuntimeDxe.efi", "Emulated NVRAM", load_early=True),
    drv("OpenRuntime.efi", "Required", load_early=True),
    drv("HfsPlusLegacy.efi", "HFS+ for CPUs without RDRAND"),
    drv("OpenUsbKbDxe.efi", "USB keyboard in picker (DuetPkg)"),
    drv("ResetNvramEntry.efi", "Reset NVRAM picker entry"),
]
c["UEFI"]["ConnectDrivers"] = True
# Mojave's APFS driver is older than the default minimum - allow any version
c["UEFI"]["APFS"].update(MinDate=-1, MinVersion=-1, EnableJumpstart=True)
c["UEFI"]["Output"].update(ProvideConsoleGop=True, TextRenderer="BuiltinGraphics", Resolution="Max")
c["UEFI"]["Input"].update(KeySupport=False)  # OpenUsbKbDxe handles the keyboard
uq = c["UEFI"]["Quirks"]
uq.update(IgnoreInvalidFlexRatio=False, RequestBootVarRouting=True, ReleaseUsbOwnership=False,
          UnblockFsConnect=False, EnableVectorAcceleration=False)
c["UEFI"]["ReservedMemory"] = []

plistlib.dump(c, open(sys.argv[1], "wb"), sort_keys=True)
