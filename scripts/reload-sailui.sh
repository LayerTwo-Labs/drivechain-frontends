#!/usr/bin/env bash
set -e

for dir in thunder bitnames bitassets zside bitassets photon truthcoin bitwindow coinshift; do
  (
    cd "$dir"
    flutter pub get
  ) &
done

for dir in thunder bitnames bitassets zside bitassets photon truthcoin bitwindow coinshift; do
  (
    cd "$dir/macos"
    pod install --repo-update
  ) &
done

wait

cd sail_ui
flutter pub get
