#!/usr/bin/env bash
set -e

for dir in sail_ui thunder bitnames zside bitassets photon truthcoin bitwindow; do
  (
    cd "$dir"
    flutter pub upgrade --major-versions --tighten
  ) &
done

wait
