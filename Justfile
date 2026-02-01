format:
    bash scripts/format.sh

gen-router:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in sail_ui bitwindow thunder bitnames zside bitassets photon truthcoin; do
        if [ -d "$dir" ]; then
            (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
        fi
    done

upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in sail_ui bitwindow thunder bitnames zside bitassets photon truthcoin; do
        if [ -d "$dir" ]; then
            (cd "$dir" && flutter pub upgrade --tighten --major-versions)
        fi
    done

gen-version:
    bash scripts/generate-version.sh bitassets
    scripts/generate-version.sh bitnames
    scripts/generate-version.sh bitwindow
    scripts/generate-version.sh thunder
    scripts/generate-version.sh zside
    scripts/generate-version.sh photon
    scripts/generate-version.sh truthcoin

gen: gen-router gen-version

test:
    #!/usr/bin/env bash
    set -uo pipefail
    failed_projects=()
    for dir in bitwindow thunder bitnames zside bitassets photon truthcoin; do
        if [ -d "$dir" ] && [ -d "$dir/test" ]; then
            echo "========================================"
            echo "Testing: $dir"
            echo "========================================"
            if ! (cd "$dir" && flutter test 2>&1); then
                failed_projects+=("$dir")
            fi
            echo ""
        fi
    done
    if [ ${#failed_projects[@]} -gt 0 ]; then
        echo "========================================"
        echo "FAILED PROJECTS: ${failed_projects[*]}"
        echo "========================================"
        exit 1
    fi