#!/bin/bash
# Check that all migration files are registered in their respective registry files.
# Exits with error if any migration file is not imported.

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
EXIT_CODE=0

check_migrations() {
    local migrations_dir="$1"
    local registry_file="$2"
    local name="$3"

    if [ ! -d "$migrations_dir" ]; then
        return 0
    fi

    if [ ! -f "$registry_file" ]; then
        echo "ERROR: Registry file not found: $registry_file"
        return 1
    fi

    # Find all NNN_*.dart files (migration files, not the registry)
    for migration_file in "$migrations_dir"/[0-9][0-9][0-9]_*.dart; do
        [ -e "$migration_file" ] || continue

        filename=$(basename "$migration_file")

        # Check if this file is imported in the registry (handles both relative and package imports)
        if ! grep -q "$filename" "$registry_file"; then
            echo "ERROR: $name migration '$filename' is not imported in $(basename "$registry_file")"
            EXIT_CODE=1
        fi
    done
}

# Bitcoin conf migrations
check_migrations \
    "$REPO_ROOT/sail_ui/lib/migrations/bitcoin_conf" \
    "$REPO_ROOT/sail_ui/lib/migrations/bitcoin_conf/bitcoin_conf_migrations.dart" \
    "bitcoin_conf"

if [ $EXIT_CODE -eq 0 ]; then
    echo "All migrations are properly registered."
else
    echo ""
    echo "Fix: Import the missing migration file(s) in the registry and add to the migrations list."
fi

exit $EXIT_CODE
