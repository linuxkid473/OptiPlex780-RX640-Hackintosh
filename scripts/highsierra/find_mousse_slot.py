#!/usr/bin/env python3
"""Tell which AAAMouSSE variant a given High Sierra kernel needs.

MouSSE hooks one 8-byte slot of the kernel's `idt64_hndl_table0`; it must be the slot that holds `hndl_alltraps`
(the handler that receives #UD).  That slot differs between builds of the SAME Darwin 17.7.0:
    xnu-4570.71.2    (10.13.6 original / our self-built kernel):  +0x28  -> needs the PATCHED kext (patch_mousse_highsierra.py)
    xnu-4570.71.82.6 (Security Update 2020-005):                 +0x40  -> needs the STOCK kext (extras/AAAMouSSE-orig)
Usage: python3 scripts/highsierra/find_mousse_slot.py /System/Library/Kernels/kernel      (any x86_64 kernel file, run anywhere)
"""
import struct, subprocess, sys

def segments(d):
    ncmds, = struct.unpack_from('<I', d, 16); off, segs = 32, []
    for _ in range(ncmds):
        cmd, size = struct.unpack_from('<II', d, off)
        if cmd == 0x19:
            vm, vs, fo, fs = struct.unpack_from('<QQQQ', d, off + 24); segs.append((vm, vs, fo))
        off += size
    return segs

def sym(path, name):
    out = subprocess.run(["nm", "-arch", "x86_64", path], capture_output=True, text=True).stdout
    for l in out.splitlines():
        p = l.split()
        if len(p) == 3 and p[2] == name: return int(p[0], 16)

path = sys.argv[1]
d = open(path, 'rb').read()
table, trap = sym(path, "_idt64_hndl_table0"), sym(path, "_hndl_alltraps")
if not table or not trap: sys.exit("symbols not found (is this an unstripped-symbol x86_64 xnu kernel?)")
fo = next(f + table - v for v, s, f in segments(d) if v <= table < v + s)
for i in range(0, 0x80, 8):
    if struct.unpack_from('<Q', d, fo + i)[0] == trap:
        print("hndl_alltraps is at idt64_hndl_table0 + %#x -> use the %s AAAMouSSE" % (
            i, "STOCK" if i == 0x40 else "PATCHED (slot %#x)" % i if i == 0x28 else "a re-patched (slot %#x)" % i))
        break
else:
    print("hndl_alltraps not found in the first 16 slots")
