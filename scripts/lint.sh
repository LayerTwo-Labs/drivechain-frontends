#!/usr/bin/env bash
set -euo pipefail

# Format all Dart files in the repository
find . -name "*.dart" -not -path "*/lib/gen/*" | xargs dart format -l 120 &

for dir in bitwindow faucet launcher sail_ui thunder zside; do
  if [ -d "$dir" ]; then
    # Run all three Dart commands in parallel for this dir
    (cd "$dir" && dart fix --apply) &
    (cd "$dir" && dart analyze) &

    # If a server directory exists, run golangci-lint inside it
    if [ -d "$dir/server" ]; then
      (cd "$dir/server" && golangci-lint run) &
    fi
  fi
done

wait