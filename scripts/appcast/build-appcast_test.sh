#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD="$SCRIPT_DIR/build-appcast.sh"
FILENAME="$SCRIPT_DIR/release-filename.sh"
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

failures=0

fail() {
    echo "FAIL: $1" >&2
    failures=$((failures + 1))
}

item() {
    local os=$1 version=$2
    cat <<EOF
    <!-- $os Release -->
    <item>
      <title>Version $version</title>
      <enclosure
        url="https://releases.drivechain.info/$os-$version"
        sparkle:version="$version"
        sparkle:os="$os" />
    </item>
EOF
}

item windows 1.0.1 > "$TMP/windows-new.xml"
item macos 1.0.1 > "$TMP/macos-new.xml"
{
    echo '<rss><channel>'
    item windows 1.0.0
    item macos 1.0.0
    echo '</channel></rss>'
} > "$TMP/live.xml"
{
    echo '<rss><channel>'
    item macos 1.0.0
    echo '</channel></rss>'
} > "$TMP/live-macos-only.xml"

count() {
    grep -c "$1" "$2" || true
}

test_both_fragments_replace_live_items() {
    "$BUILD" thunder "$TMP/live.xml" "$TMP/windows-new.xml" "$TMP/macos-new.xml" > "$TMP/out.xml"
    [ "$(count 'windows-1.0.1' "$TMP/out.xml")" = 1 ] || fail "both: no new windows item"
    [ "$(count 'macos-1.0.1' "$TMP/out.xml")" = 1 ] || fail "both: no new macos item"
    [ "$(count '1.0.0' "$TMP/out.xml")" = 0 ] || fail "both: live item kept"
}

test_missing_windows_fragment_keeps_live_windows_item() {
    "$BUILD" thunder "$TMP/live.xml" "" "$TMP/macos-new.xml" > "$TMP/out.xml"
    [ "$(count 'windows-1.0.0' "$TMP/out.xml")" = 1 ] || fail "no windows: live windows item lost"
    [ "$(count 'macos-1.0.1' "$TMP/out.xml")" = 1 ] || fail "no windows: no new macos item"
    [ "$(count 'macos-1.0.0' "$TMP/out.xml")" = 0 ] || fail "no windows: live macos item kept"
    first_os=$(grep -o 'sparkle:os="[a-z]*"' "$TMP/out.xml" | head -1)
    [ "$first_os" = 'sparkle:os="windows"' ] || fail "no windows: first item is $first_os"
}

test_missing_macos_fragment_keeps_live_macos_item() {
    "$BUILD" thunder "$TMP/live.xml" "$TMP/windows-new.xml" "" > "$TMP/out.xml"
    [ "$(count 'macos-1.0.0' "$TMP/out.xml")" = 1 ] || fail "no macos: live macos item lost"
    [ "$(count 'windows-1.0.1' "$TMP/out.xml")" = 1 ] || fail "no macos: no new windows item"
}

test_no_live_feed_uses_fragments_only() {
    "$BUILD" thunder "" "" "$TMP/macos-new.xml" > "$TMP/out.xml"
    [ "$(count '<item>' "$TMP/out.xml")" = 1 ] || fail "no live: item count"
    [ "$(count 'macos-1.0.1' "$TMP/out.xml")" = 1 ] || fail "no live: no macos item"
}

test_no_items_fails() {
    if "$BUILD" thunder "$TMP/live-macos-only.xml" "" "" > /dev/null 2>&1; then
        :
    else
        fail "macos-only live feed: carried item rejected"
    fi
    if "$BUILD" thunder "" "" "" > /dev/null 2>&1; then
        fail "no items: exit code 0"
    fi
}

test_output_is_valid_xml() {
    "$BUILD" thunder "$TMP/live.xml" "" "$TMP/macos-new.xml" > "$TMP/out.xml"
    if command -v xmllint > /dev/null; then
        xmllint --noout "$TMP/out.xml" || fail "xml: xmllint rejected output"
    fi
}

test_release_filenames() {
    [ "$("$FILENAME" bitwindow macos)" = "BitWindow-latest-x86_64-apple-darwin.zip" ] || fail "filename: bitwindow macos"
    [ "$("$FILENAME" bitwindow windows)" = "BitWindow-latest-x86_64-windows.exe" ] || fail "filename: bitwindow windows"
    for client in thunder truthcoin photon bitnames bitassets zside coinshift; do
        [ "$("$FILENAME" "$client" macos)" = "test-$client-x86_64-apple-darwin.zip" ] || fail "filename: $client macos"
        [ "$("$FILENAME" "$client" windows)" = "test-$client-x86_64-windows.exe" ] || fail "filename: $client windows"
    done
    if "$FILENAME" nosuchapp macos > /dev/null 2>&1; then
        fail "filename: unknown client accepted"
    fi
    if "$FILENAME" thunder linux > /dev/null 2>&1; then
        fail "filename: unknown os accepted"
    fi
}

test_both_fragments_replace_live_items
test_missing_windows_fragment_keeps_live_windows_item
test_missing_macos_fragment_keeps_live_macos_item
test_no_live_feed_uses_fragments_only
test_no_items_fails
test_output_is_valid_xml
test_release_filenames

if [ "$failures" -ne 0 ]; then
    echo "$failures failure(s)" >&2
    exit 1
fi
echo "all appcast tests passed"
