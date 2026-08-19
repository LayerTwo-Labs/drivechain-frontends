#!/usr/bin/env bash
set -euo pipefail

APPS=(thunder bitnames bitassets zside photon truthcoin bitwindow coinshift)

for dir in sail_ui sidechain_core "${APPS[@]}"; do
  echo "==> flutter pub get: $dir"
  (cd "$dir" && flutter pub get)
done

pids=()
for dir in "${APPS[@]}"; do
  (cd "$dir/macos" && pod install --repo-update) &
  pids+=($!)
done

status=0
for pid in "${pids[@]}"; do
  wait "$pid" || status=1
done
exit "$status"
