#!/usr/bin/env bash
# Counts `package:flutter/material.dart` imports across each top-level
# package. Use this to track the design-system migration: each phase
# should ratchet these numbers down. Run from repo root.
set -e

packages=(
  sail_ui
  bitwindow
  thunder
  bitnames
  bitassets
  zside
  truthcoin
  photon
  coinshift
)

printf "%-14s %6s\n" "package" "count"
printf "%-14s %6s\n" "-------" "-----"
total=0
for p in "${packages[@]}"; do
  if [ ! -d "$p/lib" ]; then continue; fi
  n=$(grep -rln "package:flutter/material.dart" "$p/lib" 2>/dev/null | wc -l | tr -d ' ')
  printf "%-14s %6s\n" "$p" "$n"
  total=$((total + n))
done
printf "%-14s %6s\n" "-------" "-----"
printf "%-14s %6s\n" "TOTAL" "$total"
