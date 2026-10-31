#!/usr/bin/env bash
# Usage: sync-path-dep-versions.sh <package-dir>
# Writes the current version of each path dependency into <package-dir>/pubspec.lock.
# A release bumps the version of an app that BitWindow holds as a path dependency.
set -euo pipefail

dir="$1"
lock="$dir/pubspec.lock"

awk -v base="$dir" '
  /^      path: "/ {
    dep = $2
    gsub(/"/, "", dep)
  }
  /^    source: / {
    is_path = ($2 == "path")
  }
  /^    version: "/ && is_path {
    pubspec = base "/" dep "/pubspec.yaml"
    version = ""
    while ((getline line < pubspec) > 0) {
      if (line ~ /^version: /) {
        version = substr(line, 10)
        break
      }
    }
    close(pubspec)
    if (version == "") {
      print "no version in " pubspec > "/dev/stderr"
      exit 1
    }
    print "    version: \"" version "\""
    is_path = 0
    next
  }
  { print }
' "$lock" >"$lock.tmp"
mv "$lock.tmp" "$lock"
