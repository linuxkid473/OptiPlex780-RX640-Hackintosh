# Building and booting Apple's XNU 10.13.6 kernel (xnu-4570.71.2) on the OptiPlex

**Result (verified):** a kernel compiled from Apple's published source (`apple-oss-distributions/xnu`, tag `xnu-4570.71.2`) boots the
OptiPlex 780 into High Sierra with everything intact: Metal GPU, hardware H.264 decode, patched MouSSE (SSE4.2 emulation), Ethernet,
no panics. `kern.version` reads `Darwin Kernel Version 17.7.0: <date>; <user>:xnu-src[xnu-4570.71.2-dirty]/BUILD/obj/RELEASE_X86_64`.

It is **not** byte-identical to Apple's kernel: 2,059 closed-source exports (almost all Skywalk networking, `IOSK*`) are missing, and
the only kext in `/System/Library/Extensions` that needs them is `IOSkywalkFamily`, which this machine never loads. Apple's own build also
ships CTF/dtrace data and LTO that this build skips. Treat it as an experiment, keep the restore script.

## What it needs
- The old toolchain that matches the source: the OptiPlex's own `/Library/Developer/CommandLineTools` (clang 10.0.0, SDK 10.14, `mig`,
  `migcom`, `unifdef`). It is x86_64, so it runs under Rosetta on an Apple-silicon Mac — building there was far faster than on the Core 2 Duo
  (~68 files/min under `nice` vs. the whole kernel in minutes).
- This Mac's modern `xcrun` can't load the old toolchain, so [`xcrun-shim`](xcrun-shim) answers the four queries xnu's makefiles make
  (`-find`, `-show-sdk-path`, `-show-sdk-platform-path`, `-show-sdk-version`) from the copied toolchain.
- Sources: `xnu` `xnu-4570.71.2`, `libdispatch` `libdispatch-913.60.2` (firehose headers + one source file), `libplatform` `libplatform-161.50.1`
  (`os/internal/atomic.h`, `os/base_private.h`).

## Recipe
```bash
# 0. copy the toolchain from the OptiPlex:   ssh host 'tar -cz -C /Library/Developer CommandLineTools' | tar -xz -C ./tc
export XNU_TC=$PWD/tc/CommandLineTools PATH=$PWD/bin:$PATH MACOSX_DEPLOYMENT_TARGET=10.13   # bin/ holds xcrun-shim as "xcrun" and a migcom symlink
git clone --depth 1 --branch xnu-4570.71.2 https://github.com/apple-oss-distributions/xnu
git -C xnu apply ../patches/xnu-4570.71.2-build-fixes.diff
# 1. headers Apple's internal SDK has but the public one doesn't (kernel include dir = $SDK/usr/local/include/kernel):
#    libdispatch os/firehose_buffer_private.h + os/firehose_server_private.h, run through unifdef exactly like Apple's libfirehose_kernel.xcconfig:
#    unifdef -DKERNEL=1 -DOS_FIREHOSE_SPI=1 -DOS_VOUCHER_ACTIVITY_SPI_TYPES=1 -UOS_VOUCHER_ACTIVITY_SPI <hdr> > $SDK/usr/local/include/kernel/os/<hdr>
#    libplatform private/os/internal/*.h -> $SDK/usr/local/include/os/internal/ ; private/os/*.h -> $SDK/usr/local/include/os/
# 2. libfirehose_kernel.a (the kernel links -lfirehose_kernel): compile ONE file with Apple's kernel flags and package it
#    ./make_firehose_buffer_patched.py libdispatch/src/firehose/firehose_buffer.c fb.c
#    clang -arch x86_64 -mkernel -nostdinc -O2 -DKERNEL=1 -DDISPATCH_USE_DTRACE=0 -DOS_FIREHOSE_SPI=1 -isysroot $SDK -mmacosx-version-min=10.13 \
#          -I libdispatch -I libdispatch/src -I libdispatch/src/firehose -I xnu/EXTERNAL_HEADERS -I xnu/libkern -I xnu/libkern/firehose -I xnu/osfmk -I xnu/bsd \
#          -I xnu/BUILD/obj/EXPORT_HDRS/{libkern,osfmk,bsd} -I $SDK/usr/local/include/{kernel,os,.} -I $SDK/usr/include -c fb.c -o firehose_buffer.o
#    libtool -static -arch_only x86_64 -o $SDK/usr/local/lib/kernel/libfirehose_kernel.a firehose_buffer.o
# 3. build (RELEASE x86_64, no LTO, warnings non-fatal because clang 10 is stricter than Apple's 9):
make -C xnu XCRUN=$PWD/bin/xcrun HOST_OS_VERSION=10.13 WERROR=-Wno-error SDKROOT=macosx ARCH_CONFIGS=X86_64 KERNEL_CONFIGS=RELEASE BUILD_LTO=0 MAKEJOBS=-j10
#    -> xnu/BUILD/obj/RELEASE_X86_64/kernel.  The build then ends with a dSYM error (`env: python`): harmless, the kernel is already linked.
```
Steps 1–2 must be done after a first `make` has produced `BUILD/obj/EXPORT_HDRS` (step 2 uses it); `make` fails at the link until `libfirehose_kernel.a` exists.

## What the patches fix (see [`patches/`](patches))
| File | Problem with clang 10 / this host | Fix |
|---|---|---|
| `bsd/net/if_ipsec.c` | real bug in Apple's source: uses a struct field that is `#if IPSEC_NEXUS`-guarded (and `IPSEC_NEXUS` is 0) | guard the use |
| `bsd/kern/makekdebugevents.py` | Python 2 script (`#!/usr/bin/python`, `print` statements) | Python 3 port, identical output |
| `osfmk/x86_64/idt64.s` | `movl %fs, mem` rejected by clang 10's assembler (needs `movw`) | `movl`→`movw` for segment-register stores (same 16-bit store) |
| `osfmk/i386/locks_i386.c` | clang 10 lowers a 4-byte relaxed atomic load to a `__atomic_load_4` libcall; the stock one needs `OSSpinLockLock` | provide a plain-load `__atomic_load_4` |
| `config/Private.x86_64.exports`, `osfmk/i386/pmCPU.c`, `libkern/c++/OSKext.cpp` | `IONetworkingFamily` and `pmtelemetry` (both loaded here) import closed-source symbols: `IOSKCopyKextIdentifierWithAddress`, six `xcpm_*` | export stubs (NULL / "HWP not enabled") |

Host-side gotchas: pass `HOST_OS_VERSION=10.13` (the makefile otherwise passes the host's OS version, 27.3, to clang 10); `ctfconvert`/`ctfmerge`
are not in the Command Line Tools, but the makefile then skips CTF automatically.

## Is a kernel compatible with the machine? (how we checked)
1. `nm -gU` the real kernel (extract it from `Core.pkg` in the installer: `xar -xf Core.pkg Payload`, then stream the pbzx payload) and yours; diff the exports.
2. For every kext binary in the installer's `/System/Library/Extensions`, `nm -u` and intersect with the missing exports; cross-check with `kextstat` on the target.
3. Trap table sanity for the MouSSE patch: `_idt64_hndl_table0+0x28` must be `hndl_alltraps` (it is, same source).
That found `IOSkywalkFamily` (unused), `IONetworkingFamily` (1 symbol) and `pmtelemetry` (6) — the last two are stubbed. `com.apple.nke.applicationfirewall`
(6 symbols: `kern_pbufpool_*`, `_mach_bridge_remote_time`, `_bpf_tap_packet_in/out`) was missed by the scan; kxld warns about it while building the cache,
yet the kext still loaded at runtime. Verify with `kextstat` after booting.

## Installing / reverting
[`install_custom_kernel.sh`](install_custom_kernel.sh) (run on the Mac, asks for sudo): backs up Apple's kernel and `PrelinkedKernels/` to `~/kernel-backup-<time>`, writes
`restore_apple_kernel.sh` next to them, installs the kernel as `/System/Library/Kernels/kernel` (+ a `kernel.xnubuild` copy), runs `kextcache -i /` and checks the
prelinked kernel was rebuilt (it is *compressed*, so grepping it for strings proves nothing). Needs `csr-active-config 0x67`.
**Revert** from the running system: `bash ~/kernel-backup-<time>/restore_apple_kernel.sh`; if it won't boot: USB installer → Utilities → Terminal →
`bash /Volumes/<hd>/Users/<you>/kernel-backup-<time>/restore_apple_kernel.sh /Volumes/<hd>`. `immutablekernel` (the iMac-Pro T2 cache) is left as Apple's; this setup booted from the
rebuilt `prelinkedkernel`, so it is the one OpenCore uses here.
