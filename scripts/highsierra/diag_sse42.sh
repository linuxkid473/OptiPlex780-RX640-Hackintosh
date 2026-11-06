#!/bin/bash
# Run on the installed High Sierra: copies/uses a compiled ssetest (see ssetest.c) and runs it 40 times.
# Build it on another Mac:  clang -arch x86_64 -mmacosx-version-min=10.13 -o ssetest ssetest.c
# Expect: ok=40 crashed=0 once the patched AAAMouSSE is active.  ok=0 crashed=40 = SSE4.2 emulation NOT working.
HERE="$(cd "$(dirname "$0")" && pwd)"
echo "== boot-args"; nvram boot-args; echo "== csr"; csrutil status
echo "== kextstat"; kextstat | grep -i -E "MouSSE|Lilu|WhateverGreen|AMD|RX640"
ok=0; bad=0
for i in $(seq 1 40); do "$HERE/ssetest" >/dev/null 2>&1 && ok=$((ok+1)) || bad=$((bad+1)); done
echo "== ssetest x40: ok=$ok crashed=$bad"
