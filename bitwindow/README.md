# BitWindow

Frontend for interacting with a Drivechain-enabled layer 1 Bitcoin network.

## Prerequisites

- [Dart](https://dart.dev/get-dart)
- [Flutter](https://docs.flutter.dev/install)
- [Go](https://go.dev)
- [just](https://github.com/casey/just) - command runner for justfiles

## Getting Started

```bash
just run
```

This downloads all required binaries and starts the app.

## Regtest

`scripts/regtest.sh` runs the app on a regtest datadir that stays between runs.

```bash
scripts/regtest.sh start         # start the app on regtest
scripts/regtest.sh mine 101      # mine blocks
scripts/regtest.sh save funded   # save the state
scripts/regtest.sh restore funded
scripts/regtest.sh reset         # delete the wallet and the chain, keep the binaries
```

Run `scripts/regtest.sh help` for all commands.
