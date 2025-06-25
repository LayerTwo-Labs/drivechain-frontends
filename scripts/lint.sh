#!/usr/bin/env bash
set -euo pipefail


# first run fix --apply (and any server lints)
for dir in bitwindow faucet launcher sail_ui thunder zside; do
  if [ -d "$dir" ]; then
    # Run all three Dart commands in parallel for this dir
    (cd "$dir" && dart fix --apply) &

    # If a server directory exists, run golangci-lint inside it
    if [ -d "$dir/server" ]; then
      (cd "$dir/server" && golangci-lint run) &
    fi
  fi
done

wait

# then run analyze
for dir in bitwindow faucet launcher sail_ui thunder zside; do
  if [ -d "$dir" ]; then
    # Run all three Dart commands in parallel for this dir
    (cd "$dir" && dart analyze) &
  fi
done

wait

# Finally all Dart files in all repositories
find . -name "*.dart" -not -path "*/lib/gen/*" | xargs dart format -l 120