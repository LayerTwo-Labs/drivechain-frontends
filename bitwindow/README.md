# LitWindow

LitWindow is the Litecoin/Liteverse signet adaptation branch of the upstream BitWindow frontend.

The upstream project remains BitWindow. This branch changes only UI-facing product text for now; package names, bundle identifiers, binary names, install paths, daemon names, and deep build identifiers intentionally remain unchanged until a later migration requires it.

This branch is for local Litecoin/Liteverse signet work and does not make production network assumptions.

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
