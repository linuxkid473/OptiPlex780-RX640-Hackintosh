#!/bin/bash
# Run ON the High Sierra machine (Terminal). Builds the RX 640 injector from High Sierra's own AMD kexts
# and installs it into /Library/Extensions.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
cd "$HERE"
if ! csrutil status 2>&1 | grep -q "Kext Signing: disabled"; then
  echo "SIP is blocking unsigned kexts (stage-1 config). Run ./apply_stage2.sh /Volumes/OPENCORE FIRST"
  echo "(it sets csr-active-config 0x67), reboot, then run this script again."
  exit 1
fi
rm -rf RX640Injector.kext
python make_injector.py --out RX640Injector.kext
sudo rm -rf /Library/Extensions/RX640Injector.kext
sudo cp -R RX640Injector.kext /Library/Extensions/
sudo chown -R root:wheel /Library/Extensions/RX640Injector.kext
sudo chmod -R 755 /Library/Extensions/RX640Injector.kext
sudo kextcache -i /
echo "Injector installed. Next: ./apply_stage2.sh /Volumes/<your OpenCore/EFI partition>"
