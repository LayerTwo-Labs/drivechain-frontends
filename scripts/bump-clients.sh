#!/usr/bin/env bash
set -e

for dir in sail_ui thunder bitnames zside faucet bitwindow; do
  (
    cd "$dir"
    flutter pub upgrade --major-versions --tighten
  ) &
done

wait
