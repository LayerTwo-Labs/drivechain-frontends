format:
    #!/usr/bin/env bash
    set -euo pipefail
    find . -name "*.dart" -not -path "*/lib/gen/*" | xargs dart format -l 120

lint: format
    bash scripts/lint.sh

gen-router:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in sail_ui bitwindow faucet thunder bitnames zside; do
        if [ -d "$dir" ]; then
            (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
        fi
    done

upgrade:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in sail_ui bitwindow faucet thunder bitnames zside; do
        if [ -d "$dir" ]; then
            (cd "$dir" && flutter pub upgrade)
        fi
    done

gen-version:
    bash scripts/generate-version.sh bitassets
    scripts/generate-version.sh bitnames
    scripts/generate-version.sh bitwindow
    scripts/generate-version.sh thunder
    scripts/generate-version.sh zside

gen: gen-router gen-version