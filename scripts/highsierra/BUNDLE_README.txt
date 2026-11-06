HIGH SIERRA GPU (RX 640) SETUP BUNDLE  -  run these ON THE OPTIPLEX after High Sierra is installed and booted
(via the OpenCore USB).  Build this folder on your Mac with:  scripts/make_highsierra_bundle.sh <outdir>

Full background and reasons: HIGH_SIERRA.md in the repo.

0) (optional now, or last) boot without the USB:   ./install_to_internal.sh
   Copies the USB's EFI + OpenDuet boot sectors to the internal disk's EFI partition (asks you to type YES, backs up first).

1) Build + install the injector from High Sierra's own AMD kexts:
       chmod +x *.sh
       ./install_injector.sh
   Must list personalities for AMD9500Controller, AMDRadeonX4000 and AMDRadeonX4000HWServices (4 in total on 10.13.6).
   Needs SIP's kext signing check off (csr-active-config 0x67, which both configs set). It says "allowed", not "denied".

2) Switch the USB's EFI to the GPU config (mount it first: `diskutil list`, `sudo diskutil mount diskXs1`):
       ./apply_stage2.sh /Volumes/OPENCORE
   Keeps your SMBIOS, backs up the old config as config-stage1.plist, adds SSDT-RX640-CONNECTORS.aml and the
   PATCHED AAAMouSSE.kext (the stock one does not work on High Sierra). Reboot.

3) Check:   system_profiler SPDisplaysDataType | grep -E 'Device ID|Metal|VRAM'      -> 0x6987, Metal: Supported, 4 GB
   If the picture has a purple/pink tint: Dell monitor menu -> Color -> Input Color Format -> switch to the other option
   (YPbPr fixed it here; RGB fixed it on Monterey).

If it hangs / black / WindowServer crash-loop: boot the USB installer, Utilities > Terminal, run
remove_injector_from_installer.sh (see its header), then restore config-stage1.plist as config.plist.

GPU H.264 / HEVC HARDWARE DECODE (optional, after step 3 works)
   ./hwdecode h264-1080p30.mp4        -> the REAL test: demands a GPU decoder ("hardware decoder created" + fps). Before the recipe it
                                         fails with -12913; ./hwdecode h264-1080p30.mp4 auto shows what VideoToolbox picks by default.
   ./vtcheck                          -> (weak, capability claim only; said YES on High Sierra even without a working decoder) shows "hardware decode: YES/no" for H.264 and HEVC (run it BEFORE and AFTER)
   ./apply_codec.sh /Volumes/OPENCORE -> enables the "-radcodec" recipe (SSDT-RX640-CODEC + -radcodec boot arg); backs up the
                                         config as config-before-codec.plist. Reboot, run ./vtcheck again.
   Browsers only use it if they ask for H.264: YouTube serves VP9/AV1 to Chromium/Firefox-based browsers (software decode,
   stutters on a Core 2 Duo). Use Safari, or force H.264 (h264ify-style extension) in the browser.
