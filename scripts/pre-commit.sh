#!/usr/bin/env bash
# Run `dart format` on staged Dart files and re-stage the result so the
# commit always has formatted code. Skips generated (lib/gen/**) and
# tooling (.dart_tool/**) paths.
# Install: ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit

set -euo pipefail

files=$(git diff --cached --name-only --diff-filter=ACMR -- '*.dart' \
  | grep -vE '(^|/)lib/gen/' \
  | grep -vE '(^|/)\.dart_tool/' \
  || true)

if [ -z "$files" ]; then
  exit 0
fi

# Flutter bundles `dart`. Add common install locations so the hook works
# under `git commit` (which doesn't inherit a login shell's PATH).
export PATH="/opt/homebrew/share/flutter/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

if ! command -v dart >/dev/null 2>&1; then
  echo "pre-commit: dart not found on PATH, skipping format" >&2
  exit 0
fi

# Format in place, then re-stage any file the formatter changed.
# shellcheck disable=SC2086
echo "$files" | xargs dart format
while IFS= read -r f; do
  [ -z "$f" ] && continue
  git add -- "$f"
done <<<"$files"
