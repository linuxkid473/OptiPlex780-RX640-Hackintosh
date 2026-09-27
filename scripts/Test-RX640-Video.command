#!/bin/bash
# RX 640 hardware video test (OptiPlex 780 / macOS Monterey)
# Double-click me. Encodes a 20 s, 600-frame 1080p clip twice and judges by speed + CPU load:
#   hardware = fast (well under a minute) with low CPU; software on a Core 2 Duo = minutes, both cores pinned.

cd "$(dirname "$0")" || exit 1
CLIP="rx640-test-clip.mp4"
WORK="$(mktemp -d /tmp/rx640test.XXXX)"
RESULT="RX640-video-test-result.txt"
FRAMES=600
MAX_SECONDS=90        # hardware finishes 1080p x600 frames far below this
MAX_AVG_CPU=120       # % of total (200% = both Core 2 Duo cores flat out)

line() { printf '%s\n' "------------------------------------------------------------"; }

if [ ! -f "$CLIP" ]; then
  echo "Test clip '$CLIP' not found next to this script."; read -r -p "Press Enter to close"; exit 1
fi

sample_cpu() {   # $1 = pid to watch, $2 = output file (one total-CPU% sample per line)
  while kill -0 "$1" 2>/dev/null; do
    ps -A -o %cpu= | awk '{s+=$1} END {printf "%d\n", s}' >> "$2"
    sleep 2
  done
}

run_test() {     # $1 name, $2 source, $3 preset, $4 output, $5 expected fourcc
  local name="$1" src="$2" preset="$3" out="$WORK/$4" tag="$5" cpu="$WORK/cpu_$4.txt"
  echo; echo "Running: $name ..."
  local start end secs avg fps ok
  start=$(date +%s)
  /usr/bin/avconvert --source "$src" -o "$out" -p "$preset" --replace >"$WORK/log_$4.txt" 2>&1 &
  local pid=$!
  sample_cpu "$pid" "$cpu" &
  wait "$pid"; local rc=$?
  end=$(date +%s); secs=$((end - start)); [ "$secs" -lt 1 ] && secs=1
  avg=$(awk '{s+=$1;n++} END {if(n) printf "%d", s/n; else print 0}' "$cpu" 2>/dev/null)
  fps=$(( FRAMES / secs ))
  ok="NO"
  if [ "$rc" -eq 0 ] && [ -s "$out" ] && LC_ALL=C grep -q "$tag" "$out" \
     && [ "$secs" -le "$MAX_SECONDS" ] && [ "${avg:-999}" -le "$MAX_AVG_CPU" ]; then ok="YES"; fi
  printf '  time: %ss (~%s fps)   avg CPU: %s%% of 200%%   exit: %s   format ok: %s\n' \
         "$secs" "$fps" "$avg" "$rc" "$(LC_ALL=C grep -q "$tag" "$out" 2>/dev/null && echo yes || echo no)"
  eval "$6=\$ok"
  eval "$6_detail=\"\${secs}s, ~\${fps} fps, avg CPU \${avg}%\""
}

clear
line; echo " RX 640 hardware video test"; line
system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model|Metal" | sed 's/^ */  /'

run_test "HEVC (H.265) ENCODE"                       "$CLIP"                  PresetHEVC1920x1080 hevc.mov hvc1 HEVC_ENC
run_test "HEVC DECODE + H.264 ENCODE (re-encode)"    "$WORK/hevc.mov"         Preset1920x1080     h264.mov avc1 H264_ENC

{
  line
  echo " RESULTS  ($(date))"
  line
  echo "  HEVC hardware ENCODE ............. $HEVC_ENC   ($HEVC_ENC_detail)"
  echo "  HEVC hardware DECODE + H.264 ENCODE $H264_ENC   ($H264_ENC_detail)"
  line
  if [ "$HEVC_ENC" = YES ] && [ "$H264_ENC" = YES ]; then
    echo "  >>> IS IT WORKING?  YES - hardware video encode/decode is working on the RX 640."
  elif [ "$HEVC_ENC" = YES ] || [ "$H264_ENC" = YES ]; then
    echo "  >>> IS IT WORKING?  PARTLY - see which line says NO above."
  else
    echo "  >>> IS IT WORKING?  NO - encoding fell back to software (slow / high CPU) or failed."
  fi
  line
  echo "  (rule: YES = finished in <= ${MAX_SECONDS}s with average total CPU <= ${MAX_AVG_CPU}% and correct format)"
} | tee "$RESULT"

rm -rf "$WORK"
echo; echo "Result saved to: $(pwd)/$RESULT"
read -r -p "Press Enter to close"
