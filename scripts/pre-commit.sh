#!/usr/bin/env bash
# Block commits that CI would reject. Two gates:
#   1. dart format on staged Dart files; re-stage if reformatted.
#   2. flutter analyze on every Dart project that has staged changes.
# Skips generated (lib/gen/**) and tooling (.dart_tool/**) paths.
# Install: bash scripts/install-hooks.sh

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
  echo "pre-commit: dart not found on PATH, skipping format/analyze" >&2
  exit 0
fi

# 1. Format in place, then re-stage any file the formatter changed.
# shellcheck disable=SC2086
echo "$files" | xargs dart format
while IFS= read -r f; do
  [ -z "$f" ] && continue
  git add -- "$f"
done <<<"$files"

# 2. Analyze every Flutter/Dart package that has staged changes. CI's
#    analyze step elevates info-level lints (unnecessary_import, etc.) to
#    errors, so catch them locally before they cost a CI cycle.
if ! command -v flutter >/dev/null 2>&1; then
  echo "pre-commit: flutter not found on PATH, skipping analyze" >&2
  exit 0
fi

root=$(git rev-parse --show-toplevel)
declare -a projects=()
while IFS= read -r f; do
  [ -z "$f" ] && continue
  dir=$(dirname "$f")
  # Walk up to the nearest pubspec.yaml — that's the project root.
  while [ "$dir" != "." ] && [ "$dir" != "/" ]; do
    if [ -f "$root/$dir/pubspec.yaml" ]; then
      projects+=("$dir")
      break
    fi
    dir=$(dirname "$dir")
  done
done <<<"$files"

mapfile -t projects < <(printf '%s\n' "${projects[@]}" | sort -u)

failed=0
for proj in "${projects[@]}"; do
  echo "pre-commit: analyzing $proj" >&2
  if ! (cd "$root/$proj" && flutter analyze --no-pub 2>&1); then
    failed=1
  fi
done

if [ "$failed" -ne 0 ]; then
  echo "" >&2
  echo "pre-commit: flutter analyze failed; commit blocked." >&2
  echo "Fix the issues above. Use --no-verify to bypass only as a last resort." >&2
  exit 1
fi
