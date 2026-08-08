#!/usr/bin/env bash
# Mirror every in-repo `replace` target reachable from the modules already in
# BUILD_DIR, so `go build` inside it resolves the same graph as the repo root.
#
# Usage: mirror-go-replace-deps.sh BUILD_DIR
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: $0 BUILD_DIR" >&2
  exit 1
fi

build_dir=${1%/}
repo_root=$PWD

if [ ! -d "$build_dir" ]; then
  echo "build dir $build_dir does not exist" >&2
  exit 1
fi

# Copying a module can pull in further replace targets, so re-scan until a pass
# copies nothing.
while :; do
  copied=0

  while IFS= read -r gomod; do
    # BUILD_DIR mirrors the repo layout, so strip the prefix to get the module's
    # path in the repo and resolve its relative replace targets from there.
    module_dir=$(dirname "$gomod")
    module_dir=${module_dir#"$build_dir"}
    module_dir=${module_dir#/}
    module_dir=${module_dir:-.}

    if [ ! -f "$module_dir/go.mod" ]; then
      continue
    fi

    while IFS= read -r target; do
      case "$target" in
      ./* | ../*) ;;
      *) continue ;;
      esac

      if ! resolved=$(cd "$module_dir/$target" 2>/dev/null && pwd); then
        echo "replace target $target in $module_dir/go.mod does not exist" >&2
        exit 1
      fi

      rel=${resolved#"$repo_root/"}
      if [ "$rel" = "$resolved" ] || [ -e "$build_dir/$rel" ]; then
        continue
      fi

      mkdir -p "$build_dir/$(dirname "$rel")"
      cp -r "$rel" "$build_dir/$rel"
      echo "mirrored $rel"
      copied=1
    done < <(go mod edit -json "$module_dir/go.mod" | jq -r '.Replace[]?.New.Path')
  done < <(find "$build_dir" -name go.mod -not -path "*/vendor/*")

  if [ "$copied" -eq 0 ]; then
    break
  fi
done
