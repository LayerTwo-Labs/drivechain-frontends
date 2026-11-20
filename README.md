## BitWindow - Your Portal into BTC (or ECX)!

An alternative **frontend** for your full node!

### Features

1. **Better Design** -- Looks much better. Crams more stuff onto the screen, per pixel.
2. **CUSF-aware** -- can implement any soft fork on Bitcoin, without modifying Bitcoin Core at all.
3. **BIP-300 Aware** -- Tracks special L2s called sidechains.
4. **New Features** -- Paper cheques, built-in block-explorer, hash calculator, paranoid-wallets.
- - Coin News -- A revolution in media.
- - Multisig lounge -- User-friendly multisig with automatic backup/restore.
- - Deniability -- Privacy tools.
- - And much, much more!

Instead of the Bitcoin Core wallet, we use the (superior) BDK wallet -- allowing for Bip-39 wordlists, PayNyms, etc.

### The Problem with Qt / Bitcoin Core

Finally, BitWindow is **modular**. You may fork BitWindow and change anything you like! We could have 5 or 6 different competing BitWindows -- and we should!

In contrast, the qt frontend in Bitcoin Core is tightly connected to the Bitcoin Core source code -- in order to modify it, you must get a pull request through their bureaucracy (aka impossible). Or, you have to release a whole competing full node -- which is a non-starter (since few would trust it). In contrast, BitWindow uses the real Bitcoin Core (from bitcoin.org), under the hood (via bitcoind and bitcoin-cli). BitWindow is a purely optional, cosmetic frontend!

### Other Frontends

This directory also contains (optional) frontends for: 

- [Truthcoin](truthcoin/README.md)

- [Photon](photon/README.md)

- [BitAssets](bitassets/README.md)

- [BitNames](bitnames/README.md)

- [Thunder](thunder/README.md)

- [ZSide](zside/README.md)

- [Coinshift](coinshift/README.md)

- [Drivechain Hub](dc-hub/README.md)
