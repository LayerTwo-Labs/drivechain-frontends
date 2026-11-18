#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/regtest.sh"
TMP=$(mktemp -d)
pids=()
cleanup() {
    for pid in "${pids[@]}"; do kill "$pid" 2>/dev/null || true; done
    rm -rf "$TMP"
}
trap cleanup EXIT

failures=0
fail() {
    echo "FAIL: $1" >&2
    failures=$((failures + 1))
}

export HOME="$TMP/home"
case "$(uname -s)" in
    Darwin*) app_support="$HOME/Library/Application Support"; core="$app_support/Ecash" ;;
    *)       app_support="$HOME/.local/share"; core="$HOME/.ecash" ;;
esac
enforcer="$app_support/bip300301_enforcer"
export BITWINDOW_REGTEST_DIR="$TMP/regtest dir"
D=$BITWINDOW_REGTEST_DIR

regtest() { "$SCRIPT" "$@" >/dev/null 2>&1; }

seed() {
    rm -rf "$HOME" "$D"
    mkdir -p "$D/assets/bin" "$D/regtest" "$core/regtest/wallets" "$core/signet" \
        "$enforcer/validator/regtest" "$enforcer/validator/signet" "$enforcer/wallet/regtest" \
        "$enforcer/bitcoin/regtest" "$app_support/bitwindow"
    echo bin >"$D/assets/bin/bitcoind"
    echo wallet >"$D/wallet.json"
    echo chain >"$core/regtest/wallets/w"
    echo slot >"$enforcer/validator/regtest/db"
    echo keep >"$core/signet/keep"
    echo keep >"$enforcer/validator/signet/keep"
    echo keep >"$app_support/bitwindow/keep"
}

expect_gone() { [[ ! -e "$1" ]] || fail "$2: $1 still exists"; }
expect_file() { [[ "$(cat "$1" 2>/dev/null)" == "$2" ]] || fail "$3: $1 does not hold '$2'"; }

# reset wipes the regtest state, and keeps the binaries and the other networks.
seed
regtest reset || fail "reset exited non-zero"
expect_file "$D/assets/bin/bitcoind" bin "reset"
expect_gone "$D/wallet.json" "reset"
expect_gone "$D/regtest" "reset"
expect_gone "$core/regtest" "reset"
expect_gone "$enforcer/validator/regtest" "reset"
expect_gone "$enforcer/wallet/regtest" "reset"
expect_gone "$enforcer/bitcoin/regtest" "reset"
expect_file "$core/signet/keep" keep "reset"
expect_file "$enforcer/validator/signet/keep" keep "reset"
expect_file "$app_support/bitwindow/keep" keep "reset"

# save, change, restore gives back the saved state.
seed
regtest save base || fail "save exited non-zero"
echo changed >"$D/wallet.json"
echo changed >"$enforcer/validator/regtest/db"
echo extra >"$D/extra"
regtest restore base || fail "restore exited non-zero"
expect_file "$D/wallet.json" wallet "restore"
expect_file "$core/regtest/wallets/w" chain "restore"
expect_file "$enforcer/validator/regtest/db" slot "restore"
expect_file "$D/assets/bin/bitcoind" bin "restore"
expect_gone "$D/extra" "restore"
expect_gone "$D.snapshots/base/datadir/assets" "save"
regtest save base && fail "save onto an existing snapshot passed"
regtest restore missing && fail "restore of a missing snapshot passed"
regtest save "../escape" && fail "save with a path in the name passed"

# A trailing slash on the datadir keeps the snapshots outside it.
seed
BITWINDOW_REGTEST_DIR="$D/" "$SCRIPT" save slash >/dev/null 2>&1 || fail "save with a trailing slash exited non-zero"
expect_gone "$D/.snapshots" "trailing slash"
echo changed >"$D/wallet.json"
BITWINDOW_REGTEST_DIR="$D/" "$SCRIPT" restore slash >/dev/null 2>&1 || fail "restore with a trailing slash exited non-zero"
expect_file "$D/wallet.json" wallet "trailing slash"

# reset refuses a datadir that holds other data.
seed
BITWINDOW_REGTEST_DIR="$HOME" "$SCRIPT" reset >/dev/null 2>&1 && fail "reset of HOME passed"
BITWINDOW_REGTEST_DIR="$app_support/bitwindow" "$SCRIPT" reset >/dev/null 2>&1 && fail "reset of the bitwindow datadir passed"
expect_file "$core/regtest/wallets/w" chain "refused reset"
expect_file "$app_support/bitwindow/keep" keep "refused reset"

# stop ends the daemons that name the datadir, and only those.
seed
bash -c "exec -a '$D/assets/bin/fake-daemon' sleep 300" >/dev/null 2>&1 &
pids+=($!)
own=$!
bash -c "exec -a '$D-other/fake-daemon' sleep 300" >/dev/null 2>&1 &
pids+=($!)
other=$!
bash -c "exec -a bash perl -e 'sleep 300' -- $D/regtest.log" >/dev/null 2>&1 &
pids+=($!)
shell=$!
bash -c "exec -a drivechaind perl -e 'sleep 300' -- --datadir $D" >/dev/null 2>&1 &
pids+=($!)
named=$!
sleep 1
regtest stop || fail "stop exited non-zero"
kill -0 "$own" 2>/dev/null && fail "stop left a daemon of the datadir"
kill -0 "$other" 2>/dev/null || fail "stop ended a daemon of another datadir"
kill -0 "$shell" 2>/dev/null || fail "stop ended a shell that names the datadir"
kill -0 "$named" 2>/dev/null && fail "stop left a drivechaind that names the datadir"

if ((failures > 0)); then
    echo "$failures failure(s)" >&2
    exit 1
fi
echo "regtest.sh: all tests passed"
