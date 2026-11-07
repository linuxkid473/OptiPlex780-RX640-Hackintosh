#!/usr/bin/env python3
"""Generate the patched copy of libdispatch's src/firehose/firehose_buffer.c used to build libfirehose_kernel.a.
Usage: make_firehose_buffer_patched.py <libdispatch-src>/src/firehose/firehose_buffer.c <out.c>
Why: xnu's libkern/firehose/chunk_private.h (included by this file) pulls in xnu's machine/atomic.h, which redefines
os_atomic_rmw_loop() for _Atomic pointers only and breaks this file's use on plain volatile fields (clang 10 error:
"address argument to atomic operation must be a pointer to _Atomic type"). We restore libplatform's definition right after."""
import sys
src = open(sys.argv[1]).read()
marker = "#include <chunk_private.h> // <firehose/chunk_private.h>\n"
assert marker in src, "unexpected firehose_buffer.c (need libdispatch-913.60.2)"
fix = marker + '''
#undef os_atomic_rmw_loop
#define os_atomic_rmw_loop(p, ov, nv, m, ...)  ({ \\
		bool _result = false; \\
		typeof(p) _p = (p); \\
		ov = os_atomic_load(_p, relaxed); \\
		do { \\
			__VA_ARGS__; \\
			_result = os_atomic_cmpxchgvw(_p, ov, nv, &ov, m); \\
		} while (os_unlikely(!_result)); \\
		_result; \\
	})
'''
open(sys.argv[2], "w").write(src.replace(marker, fix, 1))
