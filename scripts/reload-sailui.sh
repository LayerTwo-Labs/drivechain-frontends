#!/usr/bin/env bash
set -e

for dir in thunder zside faucet sail_ui launcher bitwindow; do
  (
    cd "$dir"
    flutter pub get
  ) &
done

wait