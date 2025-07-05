lint:
    bash scripts/lint.sh

gen-router:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in sail_ui bitwindow faucet thunder bitnames zside; do
        if [ -d "$dir" ]; then
            (cd "$dir" && dart run build_runner build --delete-conflicting-outputs)
        fi
    done
