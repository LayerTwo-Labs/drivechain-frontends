# LitWindow

LitWindow is the Litecoin/Liteverse signet adaptation branch of the upstream BitWindow frontend.

The upstream project remains BitWindow. This branch changes only UI-facing product text for now; package names, bundle identifiers, binary names, install paths, daemon names, and deep build identifiers intentionally remain unchanged until a later migration requires it.

This branch is for local Litecoin/Liteverse signet work and does not make production network assumptions.

## Local Configuration

LitWindow local config files are intentionally untracked. Use the `.example`
templates as starting points, copy them to the non-example filenames for local
use, and never commit real RPC credentials, cookies, wallet paths, or private
machine-local settings.

- `bitwindow-bitcoin.conf.example`
- `bitwindow-enforcer.conf.example`
- `lib/config.dart.example`

Keep production configuration separate from local signet/devnet configuration.

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
