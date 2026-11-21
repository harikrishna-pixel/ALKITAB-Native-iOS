#!/bin/bash
set -euo pipefail
cd "/Users/marberx/Downloads/ALKITAB-Native-iOS"

echo "== Devices =="
xcrun xctrace list devices 2>/dev/null || true
xcrun devicectl list devices 2>/dev/null || true

echo "== Build (workspace) =="
xcodebuild -workspace "NKJV Bible.xcworkspace" \
  -scheme "NKJV Bible" \
  -configuration Debug \
  -destination 'generic/platform=iOS' \
  -derivedDataPath "./DerivedDataBuild" \
  build | tee /tmp/alkitab_device_run.log | tail -40

echo "== Done =="
