#!/usr/bin/env bash
# Run a regtest stack on the Mac for BitWindow on a phone: Bitcoin Core, the
# enforcer, and an Esplora server with test routes.
set -euo pipefail

usage() {
    cat <<'EOF'
Usage: scripts/phone-regtest.sh <command> [args]

  start            Start Core, the enforcer and the Esplora server.
  stop             Stop the stack.
  status           Show the processes and the block height.
  reset            Stop, then delete the chain and the logs.
  cli <args>       Run bitcoin-cli against the regtest node.
  mine [n] [addr]  Mine n blocks (default 1) to addr (default: the Core wallet).
  defines <ios|android>
                   Print the --dart-define flags that point the phone app at this stack.

Environment:
  PHONE_REGTEST_DIR  Data and logs. Default: /tmp/phone-regtest
  ENFORCER_BIN       The bip300301_enforcer binary. Necessary for start.
  BITCOIND           Default: bitcoind on PATH. BITCOIN_CLI: bitcoin-cli on PATH.
  PHONE_REGTEST_PORT Base port. Core RPC = base, P2P +1, ZMQ +2,
                     enforcer gRPC +7, enforcer JSON-RPC +8, Esplora +17.
                     Default: 25543
EOF
}

die() { echo "phone-regtest: $*" >&2; exit 1; }

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bitwindow_dir=$(dirname "$script_dir")
D=${PHONE_REGTEST_DIR:-/tmp/phone-regtest}
base=${PHONE_REGTEST_PORT:-25543}
rpc_port=$base
p2p_port=$((base + 1))
zmq_port=$((base + 2))
grpc_port=$((base + 7))
enforcer_rpc_port=$((base + 8))
esplora_port=$((base + 17))
rpc_user=user
rpc_pass=password
bitcoind=${BITCOIND:-bitcoind}
bitcoin_cli=${BITCOIN_CLI:-bitcoin-cli}
wallet=qa

cli() { "$bitcoin_cli" -regtest -datadir="$D/core" -rpcport="$rpc_port" -rpcuser="$rpc_user" -rpcpassword="$rpc_pass" "$@"; }

pid_alive() { [[ -f "$D/$1.pid" ]] && kill -0 "$(<"$D/$1.pid")" 2>/dev/null; }

wait_for() {
    local what=$1 deadline=$((SECONDS + 60))
    shift
    until "$@" >/dev/null 2>&1; do
        ((SECONDS < deadline)) || die "$what did not start; see $D/$what.log"
        sleep 1
    done
}

esplora_ready() { curl -fsS "http://127.0.0.1:$esplora_port/blocks/tip/height"; }
enforcer_ready() { /usr/sbin/lsof -nP -iTCP:"$grpc_port" -sTCP:LISTEN; }

cmd_start() {
    [[ -n "${ENFORCER_BIN:-}" && -x "$ENFORCER_BIN" ]] || die "set ENFORCER_BIN to the bip300301_enforcer binary"
    mkdir -p "$D/core" "$D/enforcer"

    if ! pid_alive bitcoind; then
        "$bitcoind" -regtest -datadir="$D/core" -server -rest -txindex -fallbackfee=0.0002 \
            -rpcport="$rpc_port" -rpcbind=127.0.0.1 -rpcallowip=127.0.0.1 -rpcuser="$rpc_user" -rpcpassword="$rpc_pass" \
            -port="$p2p_port" -bind=127.0.0.1:"$p2p_port" -listenonion=0 -zmqpubsequence=tcp://127.0.0.1:"$zmq_port" \
            >"$D/bitcoind.log" 2>&1 &
        echo $! >"$D/bitcoind.pid"
        wait_for bitcoind cli getblockcount
    fi
    if ! cli listwallets | grep -q "\"$wallet\""; then
        cli loadwallet "$wallet" >/dev/null 2>&1 || cli createwallet "$wallet" >/dev/null
    fi
    if (($(cli getblockcount) < 101)); then
        cli generatetoaddress 101 "$(cli -rpcwallet="$wallet" getnewaddress)" >/dev/null
    fi

    if ! pid_alive esplora; then
        (cd "$bitwindow_dir/e2e" && go build -o "$D/regtest-esplora" ./cmd/regtest-esplora)
        "$D/regtest-esplora" --listen 127.0.0.1:"$esplora_port" --rpc-url http://127.0.0.1:"$rpc_port" \
            --rpc-user "$rpc_user" --rpc-pass "$rpc_pass" --wallet "$wallet" --control >"$D/esplora.log" 2>&1 &
        echo $! >"$D/esplora.pid"
        wait_for esplora esplora_ready
    fi

    if ! pid_alive enforcer; then
        "$ENFORCER_BIN" --data-dir="$D/enforcer" \
            --node-rpc-addr=127.0.0.1:"$rpc_port" --node-rpc-user="$rpc_user" --node-rpc-pass="$rpc_pass" \
            --node-zmq-addr-sequence=tcp://127.0.0.1:"$zmq_port" \
            --serve-grpc-addr=127.0.0.1:"$grpc_port" --serve-rpc-addr=127.0.0.1:"$enforcer_rpc_port" \
            --enable-wallet --wallet-auto-create --wallet-sync-source=disabled --enable-mempool \
            >"$D/enforcer.log" 2>&1 &
        echo $! >"$D/enforcer.pid"
        wait_for enforcer enforcer_ready
    fi
    cmd_status
}

cmd_stop() {
    local name
    for name in enforcer esplora; do
        if pid_alive "$name"; then kill "$(<"$D/$name.pid")"; fi
    done
    if pid_alive bitcoind; then cli stop >/dev/null; fi
    for name in enforcer esplora bitcoind; do
        for _ in $(seq 30); do pid_alive "$name" || break; sleep 1; done
        pid_alive "$name" && die "$name did not stop"
        rm -f "$D/$name.pid"
    done
    echo "phone-regtest: stopped"
}

cmd_status() {
    local name
    for name in bitcoind esplora enforcer; do
        if pid_alive "$name"; then echo "$name: runs (pid $(<"$D/$name.pid"))"; else echo "$name: stopped"; fi
    done
    if height=$(cli getblockcount 2>/dev/null); then echo "block height: $height"; fi
    echo "esplora: http://127.0.0.1:$esplora_port  enforcer: http://127.0.0.1:$grpc_port  data: $D"
}

cmd_defines() {
    local host
    case "${1:-}" in
        ios) host=127.0.0.1 ;;
        android) host=10.0.2.2 ;;
        *) die "give ios or android" ;;
    esac
    echo "--dart-define=ORCHESTRATOR_REGTEST_ESPLORA_URL=http://$host:$esplora_port" \
        "--dart-define=ORCHESTRATOR_REGTEST_ENFORCER_URL=http://$host:$grpc_port" \
        "--dart-define=PHONE_REGTEST_CONTROL_URL=http://$host:$esplora_port"
}

case "${1:-}" in
    start) cmd_start ;;
    stop) cmd_stop ;;
    status) cmd_status ;;
    reset) cmd_stop; rm -rf "${D:?}/core" "${D:?}/enforcer" "$D"/*.log ;;
    cli) shift; cli "$@" ;;
    mine) cli generatetoaddress "${2:-1}" "${3:-$(cli -rpcwallet="$wallet" getnewaddress)}" ;;
    defines) shift; cmd_defines "${1:-}" ;;
    -h|--help|help|"") usage ;;
    *) usage; exit 1 ;;
esac
