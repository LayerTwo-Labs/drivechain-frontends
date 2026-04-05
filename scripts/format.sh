#!/usr/bin/env bash
set -euo pipefail

DIRS=(bitwindow bitassets bitnames sail_ui thunder zside photon truthcoin coinshift)

has_cmd() { command -v "$1" &>/dev/null; }

# Ensure Flutter's dart is used for Flutter projects
export PATH="/opt/homebrew/share/flutter/bin:$PATH"

# Phase 1: fix (parallel per dir)
if has_cmd flutter; then
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
      (cd "$dir" && flutter pub get > /dev/null 2>&1 && dart fix --apply) &
    fi
  done
  wait
elif has_cmd dart; then
  echo "warning: using dart fix without flutter context" >&2
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
      (cd "$dir" && dart fix --apply) &
    fi
  done
  wait
else
  echo "warning: neither flutter nor dart found, skipping fix" >&2
fi

# Phase 2: golangci-lint on Go server dirs (sequential to avoid parallel runner conflicts)
if has_cmd golangci-lint; then
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir/server" ]; then
      (cd "$dir/server" && golangci-lint run)
    fi
  done
else
  echo "warning: golangci-lint not found, skipping Go lints" >&2
fi

# Phase 3: analyze (parallel per dir)
if has_cmd flutter; then
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
      (cd "$dir" && flutter analyze) &
    fi
  done
  wait
elif has_cmd dart; then
  echo "warning: using dart analyze instead of flutter analyze" >&2
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
      (cd "$dir" && dart analyze) &
    fi
  done
  wait
fi

# Phase 4: dart format via per-project justfile (parallel per dir)
if has_cmd dart; then
  for dir in "${DIRS[@]}"; do
    if [ -d "$dir" ]; then
      (cd "$dir" && just format) &
    fi
  done
  wait
fi