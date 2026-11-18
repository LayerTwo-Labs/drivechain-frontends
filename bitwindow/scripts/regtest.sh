#!/usr/bin/env bash
# Run BitWindow on a persistent regtest datadir, and wipe, save or restore its state.
set -euo pipefail
export PATH="$PATH:/usr/sbin:/sbin"

usage() {
    cat <<'EOF'
Usage: scripts/regtest.sh <command> [args]

  start              Start `just run` on regtest in its own process group.
  stop               Stop the app and every daemon it started.
  status             Show the process group, the ports and the block height.
  reset              Stop, then delete the wallet and the regtest chain. Keeps the binaries.
  save <name>        Stop, then save the full regtest state as <name>.
  restore <name>     Stop, then replace the regtest state with <name>.
  snapshots          List the saved states.
  cli <args>         Run bitcoin-cli against the regtest node.
  mine [n] [addr]    Mine n blocks (default 1) to addr (default: an anyone-can-spend output).
  env                Print the exports that point `flutter test` at this datadir.
  log                Follow the app log.

Environment:
  BITWINDOW_REGTEST_DIR   App datadir. Default: ~/.bitwindow-regtest
  REGTEST_START_TIMEOUT   Seconds that start waits for the node. Default: 600
EOF
}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
bitwindow_dir=$(dirname "$script_dir")

D=${BITWINDOW_REGTEST_DIR:-$HOME/.bitwindow-regtest}
snapshots_dir="$D.snapshots"
pgid_file="$D/regtest.pgid"
log_file="$D/regtest.log"

case "$(uname -s)" in
    Darwin*) app_support="$HOME/Library/Application Support"; core_dir="$app_support/Ecash" ;;
    *)       app_support="$HOME/.local/share"; core_dir="$HOME/.ecash" ;;
esac
enforcer_dir="$app_support/bip300301_enforcer"

# Regtest state outside $D. Each entry holds regtest data only.
external_state=(
    "$core_dir/regtest"
    "$enforcer_dir/bitcoin/regtest"
    "$enforcer_dir/validator/regtest"
    "$enforcer_dir/wallet/regtest"
)

app_ports=(30301 30400)
rpc_port=18443

die() { echo "regtest: $*" >&2; exit 1; }

check_datadir() {
    case "$D" in
        ""|/|"$HOME"|"$app_support"|"$app_support/bitwindow") die "refuse to use $D as the regtest datadir" ;;
    esac
}

running_pgid() {
    [[ -f "$pgid_file" ]] || return 1
    local pgid
    pgid=$(<"$pgid_file")
    [[ -n "$pgid" ]] && kill -0 -- "-$pgid" 2>/dev/null && echo "$pgid"
}

port_in_use() { lsof -nP -iTCP:"$1" -sTCP:LISTEN >/dev/null 2>&1; }

find_cli() { find "$D/assets/bin" -name bitcoin-cli -type f -perm -u+x 2>/dev/null | head -1; }

bitcoin_cli() {
    local cli
    cli=$(find_cli)
    [[ -n "$cli" ]] || die "no bitcoin-cli in $D/assets/bin; run start first"
    "$cli" -regtest -datadir="$core_dir" "$@"
}

node_ready() {
    local cli
    cli=$(find_cli)
    [[ -n "$cli" ]] && "$cli" -regtest -datadir="$core_dir" getblockcount >/dev/null 2>&1 && port_in_use 30301
}

cmd_start() {
    check_datadir
    if pgid=$(running_pgid); then
        echo "regtest: already runs (process group $pgid)"
        return 0
    fi
    for port in "${app_ports[@]}" "$rpc_port"; do
        port_in_use "$port" && die "port $port is in use; another BitWindow or node runs"
    done

    mkdir -p "$D"
    [[ -f "$D/bitwindow-bitcoin.conf" ]] || echo "chain=regtest" >"$D/bitwindow-bitcoin.conf"

    (
        cd "$bitwindow_dir"
        BITWINDOWD_DATADIR="$D" BITWINDOWD_LOG_CONSOLE=1 \
            nohup perl -e 'setpgrp(0, 0); exec @ARGV' just run >"$log_file" 2>&1 &
        echo $! >"$pgid_file"
    )
    local pgid deadline
    pgid=$(<"$pgid_file")
    deadline=$((SECONDS + ${REGTEST_START_TIMEOUT:-600}))
    echo "regtest: started process group $pgid; log: $log_file"

    until node_ready; do
        kill -0 -- "-$pgid" 2>/dev/null || { tail -20 "$log_file" >&2; die "the app stopped before the node was ready"; }
        ((SECONDS < deadline)) || { tail -20 "$log_file" >&2; die "the node was not ready after ${REGTEST_START_TIMEOUT:-600}s"; }
        sleep 2
    done
    echo "regtest: ready at block $(bitcoin_cli getblockcount)"
}

# Daemons that name $D on their command line. drivechaind and bitcoind detach from the process group.
stray_pids() {
    [[ -n "$D" ]] || die "empty datadir"
    ps -axo pid=,command= | REGTEST_DIR="$D" awk '
        BEGIN { d = ENVIRON["REGTEST_DIR"] }
        { pid = $1; cmd = substr($0, index($0, $2)) }
        { i = index(cmd, d); if (i == 0) next
          c = substr(cmd, i + length(d), 1)
          if (c == "" || c == " " || c == "/") print pid }'
}

cmd_stop() {
    local pgid
    if pgid=$(running_pgid); then
        kill -INT -- "-$pgid" 2>/dev/null || true
        for signal in TERM KILL; do
            for _ in $(seq 30); do
                kill -0 -- "-$pgid" 2>/dev/null || break 2
                sleep 1
            done
            kill -"$signal" -- "-$pgid" 2>/dev/null || true
        done
    fi
    local pids
    pids=$(stray_pids)
    if [[ -n "$pids" ]]; then
        # shellcheck disable=SC2086
        kill -TERM $pids 2>/dev/null || true
        for _ in $(seq 30); do
            [[ -z "$(stray_pids)" ]] && break
            sleep 1
        done
        pids=$(stray_pids)
        # shellcheck disable=SC2086
        [[ -n "$pids" ]] && kill -KILL $pids 2>/dev/null || true
    fi
    for _ in $(seq 30); do
        local busy=0
        for port in "${app_ports[@]}" "$rpc_port"; do port_in_use "$port" && busy=1; done
        ((busy == 0)) && break
        sleep 1
    done
    for port in "${app_ports[@]}" "$rpc_port"; do
        port_in_use "$port" && die "port $port is still in use after the stop"
    done
    rm -f "$pgid_file"
    echo "regtest: stopped"
}

cmd_status() {
    if pgid=$(running_pgid); then echo "process group: $pgid"; else echo "process group: none"; fi
    for port in "${app_ports[@]}" "$rpc_port"; do
        if port_in_use "$port"; then echo "port $port: listen"; else echo "port $port: free"; fi
    done
    if height=$(bitcoin_cli getblockcount 2>/dev/null); then echo "block height: $height"; fi
    echo "datadir: $D"
}

# Delete everything in $D except the downloaded binaries.
wipe_state() {
    check_datadir
    if [[ -d "$D" ]]; then
        find "$D" -mindepth 1 -maxdepth 1 ! -name assets -exec rm -rf {} +
    fi
    for path in "${external_state[@]}"; do rm -rf "$path"; done
}

cmd_reset() {
    cmd_stop
    wipe_state
    echo "regtest: state wiped; binaries kept"
}

# Copy with an APFS clone when the volume supports it.
copy_tree() {
    mkdir -p "$(dirname "$2")"
    if [[ "$(uname -s)" == Darwin* ]] && cp -Rc "$1" "$2" 2>/dev/null; then
        return 0
    fi
    rm -rf "$2"
    cp -R "$1" "$2"
}

check_name() {
    [[ "${1:-}" =~ ^[A-Za-z0-9._-]+$ ]] || die "give a snapshot name of letters, digits, '.', '_' or '-'"
}

cmd_save() {
    check_name "${1:-}"
    local dest="$snapshots_dir/$1"
    [[ -e "$dest" ]] && die "snapshot $1 exists; remove $dest first"
    [[ -d "$D" ]] || die "no regtest datadir at $D"
    cmd_stop
    mkdir -p "$dest/external"
    copy_tree "$D" "$dest/datadir"
    rm -rf "$dest/datadir/assets" "$dest/datadir/regtest.log"
    local i
    for i in "${!external_state[@]}"; do
        [[ -d "${external_state[$i]}" ]] && copy_tree "${external_state[$i]}" "$dest/external/$i"
    done
    echo "regtest: saved $1"
}

cmd_restore() {
    check_name "${1:-}"
    local src="$snapshots_dir/$1"
    [[ -d "$src/datadir" ]] || die "no snapshot $1 in $snapshots_dir"
    cmd_stop
    wipe_state
    mkdir -p "$D"
    local entry i
    for entry in "$src/datadir"/* "$src/datadir"/.[!.]*; do
        [[ -e "$entry" ]] && copy_tree "$entry" "$D/$(basename "$entry")"
    done
    for i in "${!external_state[@]}"; do
        [[ -d "$src/external/$i" ]] && copy_tree "$src/external/$i" "${external_state[$i]}"
    done
    echo "regtest: restored $1"
}

cmd_snapshots() {
    [[ -d "$snapshots_dir" ]] && ls -1 "$snapshots_dir"
}

cmd_mine() {
    local n=${1:-1} addr=${2:-}
    [[ "$n" =~ ^[0-9]+$ ]] || die "block count must be a number"
    if [[ -n "$addr" ]]; then
        bitcoin_cli generatetoaddress "$n" "$addr" >/dev/null
    else
        bitcoin_cli generatetodescriptor "$n" "raw(51)#8lvh9jxk" >/dev/null
    fi
    echo "regtest: block height $(bitcoin_cli getblockcount)"
}

command=${1:-}
[[ $# -gt 0 ]] && shift
case "$command" in
    start) cmd_start ;;
    stop) cmd_stop ;;
    status) cmd_status ;;
    reset) cmd_reset ;;
    save) cmd_save "$@" ;;
    restore) cmd_restore "$@" ;;
    snapshots) cmd_snapshots ;;
    cli) bitcoin_cli "$@" ;;
    mine) cmd_mine "$@" ;;
    env) check_datadir; printf 'export BITWINDOWD_DATADIR=%q BITWINDOWD_LOG_CONSOLE=1\n' "$D" ;;
    log) tail -f "$log_file" ;;
    -h|--help|help) usage ;;
    *) usage >&2; exit 2 ;;
esac
