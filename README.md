# Dell OptiPlex 780 + AMD Radeon RX 640 (Lexa / Polaris 23) — macOS Monterey with full Metal acceleration

A legacy-BIOS Core 2 Duo desktop from 2009 running **macOS Monterey 12.6.7** with a **Dell OEM Radeon RX 640 4 GB**
fully accelerated (`Metal: Supported`, 4 GB VRAM, Metal compositor) — a combination nobody had documented:

- **Legacy BIOS only** (no UEFI) → OpenCore via **OpenDuet**
- **Penryn CPU without SSE4.2/AVX** → **AAAMouSSE** SSE4.2 emulation for the AMD Metal driver
- **RX 640 = device `0x6987` rev `C1` ("POLARIS23")** → not supported by any macOS; the usual `0x67FF` spoof makes the
  display work but **breaks the accelerator** (`CAIL_ASICSetup() failed`)

The working answer is: **keep the real device-id**, add `0x6987` to Apple's AMD driver matching with a codeless
**injector kext loaded from `/Library/Extensions` (Auxiliary KC)**, and let **WhateverGreen reorder the connectors**
so the display runs on display pipe 0.

> Proof: [`diagnostics/proof_acceleration_working.txt`](diagnostics/proof_acceleration_working.txt)

```
Chipset Model: AMD Radeon RX 640      VRAM (Total): 4 GB
Device ID: 0x6987   Revision ID: 0x00c1   Metal: Supported
Framebuffer Depth: 30-Bit Color (ARGB2101010)
AMDRadeonX4000_AMDBaffinGraphicsAccelerator  <... registered, matched, active ...>
WindowServer: Metal compositor activated.
WhateverGreen rad: getConnectorsInfo installed 3 connectors
```

---

## Hardware

| Part | Detail |
|---|---|
| Machine | Dell OptiPlex 780 (Q45 / ICH10, **legacy BIOS only**) |
| CPU | Intel Core 2 Duo E7xxx/E8xxx @ 2.93 GHz (Penryn: SSE4.1, **no SSE4.2, no AVX**) |
| RAM | 4 GB DDR3-1066 |
| GPU | Dell OEM AMD Radeon RX 640 4 GB, `1002:6987` rev `C1`, subsys `1028:1713`, VBIOS `113-D0914300-101` (ATOMBIOS "POLARIS23"), ports: 1× DP + 2× mini-DP |
| Display | Dell SE2717H on the **full-size DisplayPort** |
| Ethernet | Intel 82567LM-3 (`8086:10DE`) |
| Audio | ADI AD1984A (AppleALC `alcid=11`) |

## Final software stack

| Item | Version / note |
|---|---|
| macOS | Monterey 12.6.7 (21G651) — also boots Mojave 10.14.6 (display only, no accel — see below) |
| OpenCore | 1.0.7 via **OpenDuet** (`boot` file + `boot0`/`boot1f32` on an MBR FAT32 partition) |
| SMBIOS | `iMacPro1,1` (dGPU-only, supported through Sequoia) |
| Lilu / WhateverGreen | 1.7.2 / 1.7.0 (**DEBUG builds currently in the EFI** — swap for RELEASE when done) |
| AAAMouSSE | 0.95-Dortania (from OpenCore Legacy Patcher) — **required** or WindowServer dies with `SIGILL` on `pcmpgtq` |
| telemetrap | Mojave+ on non-SSE4.2 |
| ASPP-Override, AppleMCEReporterDisabler | Monterey 12.3+ on Penryn with iMacPro1,1 (from OCLP) |
| RX640Injector | **codeless kext in `/Library/Extensions`** (NOT in OpenCore) — see why below |
| SIP | `csr-active-config = 0x203` (allow unsigned + unapproved kexts) |

---

## Repository layout

| Path | What |
|---|---|
| [`EFI-USB-working/`](EFI-USB-working) | **The exact EFI (+ OpenDuet `boot` file) that is booting the working machine.** `config.plist` = real-ID Monterey config. SMBIOS redacted. |
| [`extras/RX640Injector-Monterey-LE.kext`](extras/RX640Injector-Monterey-LE.kext) | **The key piece.** Install to `/Library/Extensions` (see step 6). Built from Monterey 12.6.7's own AMD personalities. |
| [`acpi-src/`](acpi-src) | SSDT sources (`.dsl`) + compiled `.aml`: connector reorder, the various spoof attempts, decompiled patched Dell DSDT |
| [`configs/`](configs) | Every `config.plist` variant tried during the journey (all SMBIOS-redacted) |
| [`scripts/`](scripts) | `make_usb_monterey.sh` (builds the legacy-boot USB), `install_internal.sh` (OpenDuet on the internal disk), `make_injector.py` (rebuild the injector for any macOS build), `build_config_*.py` (generate each config from OpenCore's `Sample.plist`) |
| [`extras/`](extras) | OpenDuet `LegacyBoot` files, AAAMouSSE, ASPP-Override, AppleMCEReporterDisabler, the (failed) OpenCore-injected injector variant |
| [`EFI-Mojave-stable-vesa/`](EFI-Mojave-stable-vesa) | Mojave EFI that boots reliably with **no** GPU acceleration (VESA 7 MB) — safe fallback |
| [`EFI-original-2020-downloaded/`](EFI-original-2020-downloaded) | The ancient OC 0.6 EFI this project started from (for reference only; don't use) |
| [`diagnostics/`](diagnostics) | Proof output, Lilu/WhateverGreen debug log and kernel AMD log from the working boot, linkev's 7050 config used as reference |
| [`AGENT_PLAYBOOK.md`](AGENT_PLAYBOOK.md) | **Step-by-step reproduction guide written for AI agents / humans**, with every dead end and the log lines that identify each failure |

**Not included on purpose:** the Dell RX 640 VBIOS ROM and the AMD GOP driver extracted from it (proprietary AMD/Dell
firmware — get the ROM from [TechPowerUp #230554](https://www.techpowerup.com/vgabios/230554/230554) if you need it; it
turned out **not** to be needed), and macOS installers.

---

## The recipe (short version)

1. **BIOS:** SATA = AHCI, Legacy USB on, TPM/TXT off, VT-d can stay (DisableIoMapper is on).
2. **USB:** MBR, FAT32 `OPENCORE` (300 MB) + HFS+ installer partition. Clone a `createinstallmedia`-style Monterey
   volume with `asr`, write OpenDuet `boot0` to the MBR and `boot1f32` to the FAT32 boot sector, mark it active, copy
   `boot` + `EFI/`. → [`scripts/make_usb_monterey.sh`](scripts/make_usb_monterey.sh)
3. **OpenCore config essentials** (all in [`EFI-USB-working/EFI/OC/config.plist`](EFI-USB-working/EFI/OC/config.plist)):
   - `Booter > Quirks > FixupAppleEfiImages = true` — **required** with OpenDuet + `SecureBootModel=Disabled`, otherwise
     `OCB: LoadImage failed - Volume Corrupt`.
   - `UEFI > APFS > MinDate/MinVersion = -1`, `HfsPlusLegacy.efi` (no RDRAND on Penryn), `OpenVariableRuntimeDxe` (LoadEarly) for emulated NVRAM.
   - `ACPI`: patched Dell `DSDT.aml` + **`SSDT-RX640-CONNECTORS.aml`** (connector reorder; **no device-id spoof**).
   - Kexts: AAAMouSSE (first), Lilu, VirtualSMC, WhateverGreen, AppleALC, Intel82566MM, SATA-unsupported, telemetrap,
     VoodooPS2, ASPP-Override + AppleMCEReporterDisabler (MinKernel 21.4.0).
   - Kernel patch `IOHIDFamily _isSingleUser → mov eax,1; ret` (MinKernel 20.0.0) for UHCI keyboards on Big Sur+.
   - `FadtEnableReset`, `ReleaseUsbOwnership`, `csr-active-config 03020000`, boot-args `-v keepsyms=1 debug=0x100 alcid=11 agdpmod=pikera`.
4. Install Monterey (fresh or upgrade) — the display works in VESA mode with this config before step 6.
5. On the Dell monitor OSD set **Input Color Format = RGB** if you ever see a purple/pink tint.
6. **Install the injector into the Auxiliary Kernel Collection** (this is what makes acceleration + display work together):
   ```bash
   sudo cp -R RX640Injector-Monterey-LE.kext /Library/Extensions/RX640Injector.kext
   sudo chown -R root:wheel /Library/Extensions/RX640Injector.kext
   sudo chmod -R 755 /Library/Extensions/RX640Injector.kext
   sudo kmutil load -p /Library/Extensions/RX640Injector.kext   # kernelmanagerd adds it to the AuxKC
   sudo reboot
   ```
   (`kmutil install --update-all` fails with *Read-only file system* on the sealed volume — use `kmutil load -p`.)

## Why it works (the short explanation)

| Approach | Chip init (`CAIL`) | Display | Why |
|---|---|---|---|
| Spoof `device-id 0x67FF` (± `revision-id 0xFF`) | ❌ `CAIL_ASICSetup() failed` | ✅ | HWLibs sees Baffin; can't init a Polaris 23. Mojave **and** Monterey HWLibs both fail. |
| Real ID + injector **in OpenCore** | ✅ | ❌ black / faint flicker | AMD kexts load before Lilu can hook them → WhateverGreen's connector override never applies → display lands on **pipe 2**, whose line buffer never runs after a legacy VBIOS POST (`VBLANK interrupt has not been generated in time`, `AMD Resyncing LB:2 failed`). |
| **Real ID + injector in `/Library/Extensions` + connector SSDT** | ✅ | ✅ | AuxKC loads late → WhateverGreen hooks `ATIController::start` → `connectors` override puts the DP on **pipe 0** → Metal works. |

Full story, all failed experiments and exact log signatures: **[AGENT_PLAYBOOK.md](AGENT_PLAYBOOK.md)**.

## Status / TODO

- [x] Monterey 12.6.7, Metal acceleration, 1080p60 30-bit on DP
- [x] Ethernet (IP via DHCP), audio kexts loaded, USB
- [ ] Switch Lilu/WhateverGreen back to RELEASE and drop `-liludbgall liludump=90`
- [x] OpenDuet + OpenCore on the internal disk — boots without the USB ([`scripts/install_internal.sh`](scripts/install_internal.sh); **never mark the protective MBR active**, see playbook §9)
- [ ] Sleep/wake: the RX 640 did **not** survive S3 on Mojave (`ATIController failed to access PCI device`) — untested on Monterey
- [ ] Mini-DP ports untested with the connector reorder

## Credits

acidanthera (OpenCore, Lilu, WhateverGreen, AppleALC, VirtualSMC, VoodooPS2), Dortania / OpenCore Legacy Patcher
(AAAMouSSE-Dortania, ASPP-Override, AppleMCEReporterDisabler, PatcherSupportPkg), Syncretic (MouSSE), telemetrap,
[AppleBreak1/EP45-UD3P-Customac](https://github.com/AppleBreak1/EP45-UD3P-Customac) (legacy-BIOS Core 2 + Polaris reference),
[linkev/Dell-Optiplex-7050-Micro-Hackintosh](https://github.com/linkev/Dell-Optiplex-7050-Micro-Hackintosh) and
[liaiby/Dell-INSPIRON-3910-EFI](https://github.com/liaiby/Dell-INSPIRON-3910-EFI) (RX 640 spoof references).
Third-party binaries keep their original licenses.

Built with Claude Code (Claude Opus 5.5).
