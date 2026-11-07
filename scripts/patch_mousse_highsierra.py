#!/usr/bin/env python3
"""Patch AAAMouSSE 0.95 (OCLP) so it works on macOS High Sierra 10.13.6 (xnu-4570.71.2, Darwin 17.7.0).

Why: MouSSE emulates SSE4.2 by replacing an entry of the kernel's `idt64_hndl_table0` with its own handler. It hooks
byte offset 0x40, which is `hndl_alltraps` on newer kernels - but on xnu-4570 offset 0x40 is `hndl_unix_scall`
(system calls) and `hndl_alltraps` (the trap handler that receives #UD) is at 0x28.  Unpatched, MouSSE loads and
"hooks" fine and never sees the illegal instruction (user programs using pcmpgtq die with SIGILL; WindowServer crashes
in AMDRadeonX4000GLDriver -> black screen).

NOTE: this patched kext is only right for xnu-4570.71.2 (10.13.6 original / a self-built kernel). Apple's updated kernel
xnu-4570.71.82.6 (Security Update 2020-005) has hndl_alltraps at +0x40 again, so use the STOCK kext there.
Check with scripts/highsierra/find_mousse_slot.py <kernel>.

The patch changes the displacement byte 0x40 -> 0x28 in the three instructions that touch the table:
    0x254b  movq %r11, 0x40(%r9)   (unhook)
    0x25d5  movq 0x40(%r9), %rbx   (save original entry)
    0x25e4  movq %rbx, 0x40(%r9)   (install hook)

Usage: python3 scripts/patch_mousse_highsierra.py extras/AAAMouSSE-orig/AAAMouSSE.kext out/AAAMouSSE.kext
Verify on the target:  scripts/highsierra/ssetest.c  (must print OK, not "Illegal instruction: 4").
"""
import os
import shutil
import sys

SITES = {0x254B: "4d895940", 0x25D5: "498b5940", 0x25E4: "49895940"}   # offset -> expected original bytes
REL = os.path.join("Contents", "MacOS", "MouSSE")

if len(sys.argv) != 3:
    sys.exit(__doc__)
src, dst = sys.argv[1], sys.argv[2]
if os.path.exists(dst):
    shutil.rmtree(dst)
shutil.copytree(src, dst)
path = os.path.join(dst, REL)
data = bytearray(open(path, "rb").read())
for off, exp in SITES.items():
    if data[off:off + 4].hex() != exp:
        sys.exit("unexpected bytes at 0x%x: %s (is this MouSSE 0.95-Dortania?)" % (off, data[off:off + 4].hex()))
    data[off + 3] = 0x28
open(path, "wb").write(data)
sig = os.path.join(dst, "Contents", "_CodeSignature")   # its hashes no longer match the patched binary
if os.path.isdir(sig):
    shutil.rmtree(sig)
print("patched %d sites -> %s" % (len(SITES), dst))
