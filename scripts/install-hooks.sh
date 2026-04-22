#!/usr/bin/env bash
# Install the repo's git hooks into .git/hooks/ so they fire on commit.
set -euo pipefail

root=$(git rev-parse --show-toplevel)
cd "$root"

ln -sf ../../scripts/pre-commit.sh .git/hooks/pre-commit
chmod +x scripts/pre-commit.sh

echo "installed: .git/hooks/pre-commit -> scripts/pre-commit.sh"
