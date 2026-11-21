#!/usr/bin/env bash
# Build or load the regtest load fixture with mainnet-sized blocks, wallets and mempool.
set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin:/opt/homebrew/bin"

usage() {
    cat <<'EOF'
Usage: scripts/mainnet-fixture.sh <command> [args]

  build [base] [name]   Restore snapshot base (default qa-funded), fill it, and save it as name
                        (default qa-mainnet-shape). Needs BITWINDOW_APP.
  mempool [count] [churn]
                        Add count (default 25000) transactions to the mempool of a running node.
                        With churn > 0, add that many per second until a signal stops it.

Environment: the regtest.sh variables, plus
  BITWINDOW_APP         The BitWindow binary that build starts, such as
                        build/macos/Build/Products/Profile/BitWindow.app/Contents/MacOS/BitWindow
EOF
}

die() { echo "mainnet-fixture: $*" >&2; exit 1; }

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bitwindow_dir=$(dirname "$script_dir")
RT="$script_dir/regtest.sh"
D=${BITWINDOW_REGTEST_DIR:-$HOME/.bitwindow-regtest}
home=${BITWINDOW_HOME:-$HOME}
offset=${BITWINDOW_PORT_OFFSET:-0}
case "$(uname -s)" in
    Darwin*) core_dir="$home/Library/Application Support/Ecash" ;;
    *) core_dir="$home/.ecash" ;;
esac
rpc_url="http://127.0.0.1:$((18443 + offset))"
cookie="$core_dir/regtest/.cookie"
orch="http://127.0.0.1:$((30400 + offset))"
tool="$D/assets/mainnetfixture"

build_tool() {
    (cd "$bitwindow_dir/server" && go build -o "$tool" ./tools/mainnetfixture)
}

# wm <method> <json> calls a WalletManagerService method of drivechaind.
wm() {
    curl -sf -H "Authorization: Bearer $(cat "$D/.auth.cookie")" -H 'Content-Type: application/json' \
        -d "$2" "$orch/walletmanager.v1.WalletManagerService/$1" || die "drivechaind $1 failed"
}

json() { python3 -c "import json,sys; print(json.load(sys.stdin)$1)"; }

app_pid=""
stop_app() {
    [[ -n "$app_pid" ]] && kill "$app_pid" 2>/dev/null || true
    "$RT" stop >/dev/null
}

cmd_build() {
    local base=${1:-qa-funded} name=${2:-qa-mainnet-shape}
    [[ -x "${BITWINDOW_APP:-}" ]] || die "set BITWINDOW_APP to a BitWindow binary"
    build_tool
    "$RT" restore "$base" >/dev/null

    # Mainnet confs carry txindex=1, so the parser reads OP_RETURN fees as it does there.
    if ! grep -q '^txindex=1' "$D/bitwindow-bitcoin.conf"; then
        awk '{ print } /^\[regtest\]$/ { print "txindex=1" }' "$D/bitwindow-bitcoin.conf" >"$D/bitwindow-bitcoin.conf.tmp"
        mv "$D/bitwindow-bitcoin.conf.tmp" "$D/bitwindow-bitcoin.conf"
    fi

    BITWINDOW_DEFAULT_NETWORK=regtest BITWINDOWD_DATADIR="$D" BITWINDOWD_LOG_CONSOLE=1 \
        "$BITWINDOW_APP" >"$D/fixture-app.log" 2>&1 &
    app_pid=$!
    trap stop_app EXIT
    for _ in $(seq 300); do
        "$RT" cli getblockcount >/dev/null 2>&1 && [[ -f "$D/.auth.cookie" ]] &&
            curl -sf -o /dev/null -H "Authorization: Bearer $(cat "$D/.auth.cookie")" -H 'Content-Type: application/json' \
                -d '{}' "$orch/walletmanager.v1.WalletManagerService/ListWallets" && break
        sleep 1
    done

    local app_id app_core second_id second_core watch_id desc
    app_id=$(wm ListWallets '{}' | json "['activeWalletId']")
    app_core=$(wm CreateBitcoinCoreWallet "{\"walletId\":\"$app_id\"}" | json "['coreWalletName']")

    second_id=$(wm GenerateWallet '{"name":"Fixture second"}' | json "['walletId']")
    second_core=$(wm CreateBitcoinCoreWallet "{\"walletId\":\"$second_id\"}" | json "['coreWalletName']")

    "$RT" cli -named createwallet wallet_name=fixture-watch-source load_on_startup=true >/dev/null
    desc=$("$RT" cli -rpcwallet=fixture-watch-source listdescriptors |
        json "['descriptors']" | python3 -c "import sys,ast; print(next(d['desc'] for d in ast.literal_eval(sys.stdin.read()) if d['desc'].startswith('wpkh') and not d['internal']))")
    watch_id=$(wm CreateWatchOnlyWallet "{\"name\":\"Fixture watch\",\"xpubOrDescriptor\":\"$desc\"}" | json "['walletId']")
    wm CreateBitcoinCoreWallet "{\"walletId\":\"$watch_id\"}" >/dev/null
    wm SwitchWallet "{\"walletId\":\"$app_id\"}" >/dev/null

    "$tool" build -rpc "$rpc_url" -cookie "$cookie" \
        -app-wallet "$app_core" -second-wallet "$second_core" -watch-source fixture-watch-source

    stop_app
    trap - EXIT
    "$RT" save "$name"
}

cmd_mempool() {
    local count=${1:-25000} churn=${2:-0} app_core
    build_tool
    app_core=$(wm ListWallets '{}' | json "['activeWalletId']")
    app_core=$(wm CreateBitcoinCoreWallet "{\"walletId\":\"$app_core\"}" | json "['coreWalletName']")
    exec "$tool" mempool -rpc "$rpc_url" -cookie "$cookie" -count "$count" -churn "$churn" -app-wallet "$app_core" -seed "$RANDOM"
}

command=${1:-}
[[ $# -gt 0 ]] && shift
case "$command" in
    build) cmd_build "$@" ;;
    mempool) cmd_mempool "$@" ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
esac
