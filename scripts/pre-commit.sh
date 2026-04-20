#!/usr/bin/env bash
# Run `dart format --set-exit-if-changed` on staged Dart files.
# Skips generated (lib/gen/**) and tooling (.dart_tool/**) paths.
# Install: ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit

set -euo pipefail

files=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' \
  | grep -vE '(^|/)lib/gen/' \
  | grep -vE '(^|/)\.dart_tool/' \
  || true)

if [ -z "$files" ]; then
  exit 0
fi

export PATH="/opt/homebrew/share/flutter/bin:$PATH"

if ! command -v dart >/dev/null 2>&1; then
  echo "pre-commit: dart not found on PATH, skipping format check" >&2
  exit 0
fi

echo "$files" | xargs dart format --set-exit-if-changed
