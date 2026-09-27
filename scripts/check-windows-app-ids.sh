#!/bin/bash
# Check that every Windows installer config holds a unique app_id and
# display_name. Inno Setup keys the install directory and the uninstall
# entry on app_id, so a shared value makes one client replace another.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXIT_CODE=0

check_field() {
    local field="$1"
    local seen=""

    for config in "$REPO_ROOT"/*/windows/packaging/exe/make_config.yaml; do
        [ -e "$config" ] || continue

        local client value key owner
        client=$(basename "$(dirname "$(dirname "$(dirname "$(dirname "$config")")")")")
        value=$(grep "^$field:" "$config" | head -1 | cut -d: -f2-)
        value=$(echo "$value" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' \
            -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'\$/\1/")

        if [ -z "$value" ]; then
            echo "ERROR: $client has no $field in make_config.yaml"
            EXIT_CODE=1
            continue
        fi

        # Windows reads a registry key and a path without case, so two
        # spellings of one id still name one install.
        key=$(echo "$value" | tr '[:upper:]' '[:lower:]')

        owner=$(echo "$seen" | grep "^$key " | head -1 | cut -d' ' -f2)
        if [ -n "$owner" ]; then
            echo "ERROR: $client and $owner share $field '$value'"
            EXIT_CODE=1
            continue
        fi

        seen="$seen$key $client
"
    done
}

check_field app_id
check_field display_name

if [ $EXIT_CODE -eq 0 ]; then
    echo "Every Windows installer config is unique."
else
    echo ""
    echo "Fix: give the client its own app_id (uuidgen) and its own display_name."
fi

exit $EXIT_CODE
