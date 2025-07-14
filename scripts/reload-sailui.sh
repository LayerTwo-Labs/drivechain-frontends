#!/usr/bin/env bash
set -e

for dir in thunder bitnames zside faucet sail_ui bitwindow; do
  (
    cd "$dir"
    flutter pub get
  ) &
done

for dir in thunder bitnames bitassets zside bitwindow; do
  (
    cd "$dir/macos"
    pod install --repo-update
  ) &
done

wait
