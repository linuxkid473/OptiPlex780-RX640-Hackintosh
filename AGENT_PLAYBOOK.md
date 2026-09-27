# Agent playbook: Legacy-BIOS Core 2 + AMD RX 640 (Lexa/Polaris 23) → accelerated macOS

Written so another AI agent (or a human) can reproduce or adapt this without repeating ~40 failed reboots.
Every claim below was observed on the real machine; log lines are quoted exactly so you can grep for them.

---

## 0. Ground rules that saved time

- **Get SSH to the target machine as early as possible.** Enable *System Preferences → Sharing → Remote Login*,
  install your key with `ssh-copy-id`, and on Monterey also tick **"Allow full disk access for remote users"**
  (otherwise `cp` onto the USB's FAT32 partition fails with `Operation not permitted`). With SSH you can edit the
  USB's EFI *on the target* (`diskutil mount diskXs1`) and never move the stick.
- The target's DHCP address changes between installs (`.232` → `.234`); find it with `dns-sd -G v4 <hostname>.local`.
  A fresh install regenerates SSH host keys — verify the fingerprint on the target
  (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) before replacing `known_hosts`.
- On Monterey the default shell is zsh, where **`log` is a builtin** — always call **`/usr/bin/log show ...`**.
- Use **DEBUG Lilu + WhateverGreen** with `-liludbgall liludump=90`; the dump lands in `/var/log/Lilu_<ver>_<kernel>.txt`
  90 s after boot. **Truncate it before each test boot** (`: > /var/log/Lilu_*.txt`) — Lilu overwrites in place and
  stale tail content from older boots will mislead you. Kernel-log copies of Lilu messages are rate-limited/lossy;
  `ioreg` is the ground truth.
- Validate every config with OpenCore's `ocvalidate` before deploying.

## 1. Identify the card precisely

```
system_profiler SPDisplaysDataType          # Device ID / Revision ID
ioreg -lw0 -r -n GFX0 -d 1 | grep -E 'device-id|revision-id|subsystem'
```
Dell OEM RX 640: `0x6987` rev `0xC1`, subsys `1028:1713`. The VBIOS string (inside `ATY,bin_image`) says
`POLARIS23`. This is **not** the classic Lexa RX 550 (`0x699F`). Mojave's AMDRadeonX4000HWLibs has no `POLARIS23`
strings; Monterey 12.5's has more `0x6987` table entries (19 vs 14) — still not enough for the spoofed path.

## 2. Legacy BIOS boot (OpenDuet)

- OpenCore release `Utilities/LegacyBoot`: `boot0` → MBR (`fdisk -uy -f boot0 /dev/rdiskN`), `boot1f32` → FAT32 PBR
  (keep bytes 3..89 = BPB from the original sector), `bootX64` → `/boot` at the FAT32 root, partition 1 **active**.
  `fdisk -e` prints scary "could not open MBR file" / "could not be accessed exclusively" messages — harmless.
- **`Booter > Quirks > FixupAppleEfiImages = true` is mandatory** with OpenDuet + `SecureBootModel = Disabled`.
  Symptom without it: `OCB: LoadImage failed - Volume Corrupt` when selecting any macOS entry.
- Legacy has no NVRAM: `OpenVariableRuntimeDxe.efi` + `OpenRuntime.efi` with `LoadEarly = true`, `LegacyOverwrite`, `WriteFlash`.
- Penryn has no RDRAND: use `HfsPlusLegacy.efi`. USB keyboard in picker: `OpenUsbKbDxe.efi` with `KeySupport = false`
  (ocvalidate forbids it together with `Ps2KeyboardDxe` or `KeySupport`).
- APFS on Mojave/Monterey: `UEFI > APFS > MinDate = -1, MinVersion = -1`.

## 3. DeviceProperties gotcha on this board

The patched Dell DSDT sets `PCI0._UID = 0x04`, so macOS matches the slot as **`PciRoot(0x4)`**, not `PciRoot(0x0)`.
DeviceProperties at `PciRoot(0x0)/Pci(0x1,0x0)/Pci(0x0,0x0)` were silently ignored. The robust fix is an **SSDT with a
`_DSM` on `\_SB.PCI0.PEG0.GFX0`** (see `acpi-src/`), which is path-agnostic. (WhateverGreen also sets `model` by itself,
so seeing "AMD Radeon RX 640" in ioreg does **not** prove your properties applied.)

## 4. CPU: SSE4.2 emulation is mandatory for AMD Metal

With acceleration up but no MouSSE, WindowServer crash-loops:
```
Exception Type: EXC_BAD_INSTRUCTION (SIGILL)
0 com.apple.AMDMTLBronzeDriver  amdMtlBronzeGetTexLayoutInfo(...) + 551
```
Disassembly at that offset is `pcmpgtq %xmm2, %xmm0` (SSE4.2). Fix: **AAAMouSSE 0.95-Dortania** (OCLP
`payloads/Kexts/SSE/`), loaded first. Also keep **telemetrap** (Mojave+).

## 5. The GPU saga — what each approach does (the important part)

### 5a. Spoof to Baffin `device-id 0x67FF` (SSDT or DeviceProperties)
- AMD kexts match (they list `0x67FF1002`), load **late** (after Lilu), WhateverGreen hooks everything.
- Mojave, later also Monterey:
  ```
  AMDRadeonX4000HWLibs  CAIL_ASICSetup() failed (CAILRESULT=1)
  initializeAdapter() failed!
  IOGraphicsAccelerator2::start(IOService *): configureDevice failed
  WindowServer: dev counts are zero (0, 0) - disabling OpenGL
  ```
- Adding `revision-id = 0xFF` (Dell Inspiron 3910 RX 640 recipe) **does not help** on Mojave or Monterey (it works for
  AVX2 machines on Sonoma per those repos; on non-AVX2 you are stuck with ≤ Monterey 12.5 AMD drivers anyway).
- Spoof to `0x699F` (Lexa) + injector for `0x699F`: also `CAIL_ASICSetup() failed`.
- Result: **display works (with the connector reorder), no acceleration.**

### 5b. Real ID `0x6987` + codeless injector injected **by OpenCore**
- Injector = copies of the `0x67FF1002` personalities from `AMD9500Controller`, `AMDRadeonX4000`
  (`AMDBaffinGraphicsAccelerator`) and `AMDRadeonX4000HWServices` (`...HWServicesPolaris`) with `IOPCIMatch = 0x69871002`.
- **CAIL succeeds**, accelerator starts, Metal compositor activates, Screen Sharing shows a perfect desktop...
- ...but the physical display is black with a faint flicker every ~2 s:
  ```
  AMDFramebuffer  CRITICAL ERROR : VBLANK interrupt has not been generated in time!
  AMDSupport      AMD Recovery Display.
  AMDFramebuffer  FB: 2 - Time Out Waiting for 20 transactions to complete.
  AMDSupport      --> AMD Resyncing LB:2. Iteration: 0.   ...   AMD Resyncing LB:2 failed. Could not recover.
  ```
  The monitor is attached to **framebuffer/pipe 2** (VBIOS connector order puts the full-size DP third).
- Things that did **not** fix it: `-rad24`, `CFG,CFG_NO_MSI` (MSI isn't the problem), sleep/wake (card doesn't return
  from S3: `ATIController failed to access PCI device`), loading the card's own UEFI GOP (extracted from the VBIOS)
  via OpenDuet + `ReconnectGraphicsOnConnect` (caused `TestVRAM FAILED` → kernel panic).
- **Root cause of "can't fix it":** the injector's personalities live in the prelinked/boot collection, so
  `AMDSupport`/`AMD9500Controller` load at kext index ~65 — **before Lilu's kext-load hook exists**. The Lilu log never
  shows `newly loaded kext ... AMDSupport` nor `rad: starting controller`, so WhateverGreen's `connectors` override,
  TestVRAM skip, etc. never apply. Removing `OSBundleRequired`, `IOResourceMatch boot-uuid-media` / `IOBSD` — none
  delayed it enough.

### 5c. ✅ Real ID + injector in `/Library/Extensions` (Auxiliary KC) + connector-reorder SSDT
- Put the injector in `/Library/Extensions` (root:wheel, 755), `sudo kmutil load -p` it, SIP `0x203`, reboot.
- kernelmanagerd log: `existing, loadable, and approved auxiliary kext collection direct loads: ... RX640Injector` /
  `AuxKC bundle com.optiplex780.RX640Injector marked as loadable`.
- The AuxKC loads after Lilu/WhateverGreen are live → Lilu log shows
  `rad: starting controller`, `getConnectorsInfo installed 3 connectors`.
- `SSDT-RX640-CONNECTORS` provides `connectors` + `connector-count` with the full-size DP (`txmit 0x10 enc 0x00
  hotplug 3 sense 3`) first, so the display lands on **framebuffer 0**; CAIL sees the real Polaris 23 and succeeds.
- Verify:
  ```
  system_profiler SPDisplaysDataType | grep -E 'Device ID|Metal'     # 0x6987, Metal: Supported
  ioreg -lw0 -r -c AMDFramebuffer | grep -E '\+-o display|IOFBDependentIndex'   # display0 under index 0
  ioreg -lw0 -r -c IOAccelerator | grep AMD                            # BaffinGraphicsAccelerator active
  ```

Connector bytes (16-byte legacy format, from WhateverGreen's autodetect log):
```
type 00000400 (DP) flags 00000304 feat 0100 pri 0000 txmit 11 enc 02 hotplug 05 sense 01   <- mini-DP
type 00000400 (DP) flags 00000304 feat 0100 pri 0000 txmit 21 enc 03 hotplug 04 sense 02   <- mini-DP
type 00000400 (DP) flags 00000304 feat 0100 pri 0000 txmit 10 enc 00 hotplug 03 sense 03   <- full-size DP (monitor)
```
Reordered with the full-size DP first and priority 1 → see `acpi-src/SSDT-RX640-CONNECTORS.dsl`.

## 6. Monterey-on-Penryn specifics
- `ASPP-Override.kext` (12.3+ X86PlatformPlugin matches old CPUs) and `AppleMCEReporterDisabler.kext` (iMacPro1,1 on
  non-Xeon, 12.3+), both from OCLP, `MinKernel 21.4.0`.
- `IOHIDFamily` patch `_isSingleUser` → `B8 01 00 00 00 C3` (MinKernel 20.0.0): ICH10 routes low-speed keyboards/mice
  to UHCI companions even on the USB 2.0 ports.
- `FadtEnableReset`, `ReleaseUsbOwnership` (from the EP45-UD3P Monterey EFI).
- Intel82566MM (Leopard-era kext for 82567LM-3) still works on Monterey 12.6.7.
- `kmutil install --update-all` → `Read-only file system` (tries to rebuild sealed boot/system KCs). Use `kmutil load -p`.

## 7. Misc symptoms → causes
| Symptom | Cause / fix |
|---|---|
| Purple/pink tint on the desktop over DP | Monitor interpreting colour format wrong → monitor OSD *Input Color Format = RGB* |
| Solid purple screen, then black with `-rad24` | Same pipe-2 problem as 5b, not a colour issue |
| `7 MB` VRAM, "No Kext Loaded" | AMD kexts didn't match — check device-id actually applied (`PciRoot(0x4)` / SSDT) |
| Boot sticks at kernel panic `TestVRAM FAILED ... AMDHWRegisters::read` | Something re-initialised the card (the GOP experiment) and WhateverGreen's TestVRAM skip wasn't hooked |
| DHCP fails (169.254.x.x) | Renew lease / replug; the link itself is fine |

## 8. Reproduce from this repo
1. Build the USB: `DISK=diskN USB_NAME="..." USB_BYTES=... ./scripts/make_usb_monterey.sh "/Volumes/Install macOS Monterey"`
   (a `createinstallmedia` volume or a converted installer ISO mounted read-only).
2. Put your own SMBIOS into `EFI/OC/config.plist` (`macserial -m iMacPro1,1`), run `ocvalidate`.
3. Boot, install Monterey, then do README step 6 with `extras/RX640Injector-Monterey-LE.kext`.
   If your macOS build differs from 12.6.7, **regenerate the injector from that system's own
   `/System/Library/Extensions/{AMD9500Controller,AMDRadeonX4000,AMDRadeonX4000HWServices}.kext/Contents/Info.plist`**
   (copy every personality whose `IOPCIMatch` contains `0x67FF1002`, set `IOPCIMatch = 0x69871002`) — the generator
   script is [`scripts/make_injector.py`](scripts/make_injector.py) (run it on the target Mac).
4. If your card's connector order differs, read `WhateverGreen con: ...` lines from the DEBUG Lilu log and rebuild
   `SSDT-RX640-CONNECTORS.dsl` with your monitor's port first.

## 9. Booting without the USB (OpenDuet on the internal GPT disk)

Script: [`scripts/install_internal.sh`](scripts/install_internal.sh) — run on the target with `sudo`, booted from the USB,
after copying `extras/LegacyBoot/{boot0,boot1f32,bootX64}` to `/tmp`. It backs up sector 0 + the ESP, copies the USB's
`EFI/` and `boot` to the internal FAT32 ESP, writes `boot1f32` to the ESP's PBR (keeping its BPB) and `boot0` into the
MBR boot code only (`fdisk -uy -f boot0`, partition table untouched). Monterey needs *Remote Login → "Allow full disk
access for remote users"* for this over SSH.

**⚠️ Do NOT mark the GPT protective-MBR entry (type `0xEE`) active.** We did (`fdisk -e`, `f 1`, byte 446 = `0x80`) because
some Dell BIOSes want an active partition. Result: the internal disk showed **`BOOT FAIL`**, and even booting from the
USB, **OpenCore no longer listed the Monterey volume** — OpenDuet's EDK2-derived partition driver doesn't accept a
protective MBR whose boot indicator isn't `0x00`, so it stops treating the disk as GPT and the APFS container
disappears. The OptiPlex 780 BIOS boots the internal disk fine with the flag at `0x00`.

Recovery (from the Monterey installer's Terminal, booted from the USB — no `od`/`xxd`/`python` there, `tr` works):
```bash
dd if=/dev/rdisk0 of=/tmp/s bs=512 count=1
dd if=/tmp/s bs=1 skip=446 count=1 2>/dev/null | LC_ALL=C tr '\200\000' 'AZ'; echo   # A = 0x80 (bad), Z = 0x00
printf '\000' | dd of=/tmp/s bs=1 seek=446 conv=notrunc
diskutil unmountDisk force disk0            # otherwise: dd: /dev/rdisk0: Resource busy
dd if=/tmp/s of=/dev/rdisk0 bs=512 count=1
```
Also: raw devices (`/dev/rdiskN`) only allow whole-sector I/O — `dd bs=1`/`bs=440` reads return nothing, so always read
a full 512-byte sector into a file and inspect the file.

## 10. Audio on Monterey (ADI codec, speakers on the rear headphone/line-out jack)

- **AppleALC (`alcid=11`) did not work**: AppleALC loaded, but `AppleHDAController` never attached to `HDEF`
  (`ioreg -r -n HDEF` shows no children, `system_profiler SPAudioDataType` shows no devices). IRQs were not the cause —
  the patched DSDT already has the HPET (IRQ 0/8) / RTC fixes and AppleHPET/AppleRTC load.
- **VoodooHDA injected by OpenCore silently does nothing on Big Sur+**: it links against `com.apple.iokit.IOAudioFamily`,
  which lives in the System KC; OpenCore-injected kexts can only link against the Boot KC.
- **Working fix: VoodooHDA 2.9.2 in `/Library/Extensions` (Auxiliary KC)**, AppleALC + OC's VoodooHDA entry disabled:
  ```bash
  sudo cp -R VoodooHDA.kext /Library/Extensions/ && sudo chown -R root:wheel /Library/Extensions/VoodooHDA.kext
  sudo chmod -R 755 /Library/Extensions/VoodooHDA.kext
  sudo kmutil load -p /Library/Extensions/VoodooHDA.kext
  #  -> "Extension ... not approved to load. Please approve using System Preferences."
  ```
  Then **System Preferences → Security & Privacy → General → Allow** (on the machine itself), restart, pick the output in
  Sound preferences. Codeless kexts (like RX640Injector) don't need this approval; kexts with an executable do, even with
  `csr-active-config 0x203`.
- Final internal-EFI boot-args: `keepsyms=1 debug=0x100 agdpmod=pikera -liludbgall liludump=90` (no `-v`, no `alcid`).

## 11. Hardware video encode/decode (`-radcodec` without breaking CAIL)

The video engine (`AMDRadeonX4000_AMDAccelVideoContext::getHWInfo`) doesn't know PID `0x6987`, so there's no
VideoToolbox hardware encoder. The classic fix — spoof to `0x67FF` + `-radcodec` — breaks CAIL (§5a). What works:

- Keep the **real ID in PCI config space**, but set only the **IORegistry `device-id` property** to `0x67FF` and add
  WhateverGreen's **`no-gfx-spoof`** property (WhateverGreen then does *not* hook `configRead16/32`, so HWLibs/CAIL still
  read `0x6987` and initialise the Polaris 23 correctly).
- Add **`-radcodec`**: WhateverGreen wraps `getHWInfo` and replaces the PID with the `codec-device-id` property, falling back
  to `device-id` — log line: `rad: getHWInfo: original PID: 0x6987, replaced PID: 0x67FF`.
  (`getOSData codec-device-id was not found` is harmless because of that fallback.)
- Everything lives in [`acpi-src/SSDT-RX640-CODEC.dsl`](acpi-src/SSDT-RX640-CODEC.dsl) (connectors + `device-id` + `no-gfx-spoof`),
  which replaces `SSDT-RX640-CONNECTORS.aml`. The injector in `/Library/Extensions` stays as is.
- Result: Metal unchanged, display on FB0, `system_profiler` shows `Device ID: 0x67ff` / `Revision ID: 0x00c1`.
  Measured on the Core 2 Duo: 600-frame 1080p → HEVC in **29 s** with `VTEncoderXPCService` ~0% CPU (software HEVC would
  take minutes); HEVC playback smooth, `VTDecoderXPCService` 1–3% CPU.
- Measure yourself: `time avconvert --source clip.mp4 -o out.mov -p PresetHEVC1920x1080 --replace`
  (use an HEVC source for the H.264 test, otherwise avconvert just passes H.264 through), or double-click
  [`scripts/Test-RX640-Video.command`](scripts/Test-RX640-Video.command) with a clip named `rx640-test-clip.mp4` next to it.

