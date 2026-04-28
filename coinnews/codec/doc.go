// Package coinnews is the reference implementation of the CoinNews
// OP_RETURN protocol described in docs/coinnews-protocol.md.
//
// The package is intentionally indexer-agnostic: it knows how to turn
// CoinNews messages into bytes and bytes back into messages, and it
// knows how to verify Schnorr signatures, but it does not touch a
// database, an RPC, or a Bitcoin Core node. Higher layers wire the
// codec into the indexer (`bitwindow/server/engines/...`), the gRPC
// surface (`bitwindow/server/proto/misc/v1/`), and the Dart UI.
//
// All numeric layouts and tag byte assignments come from the BIP;
// any divergence between this code and the spec is a bug in this
// code.
package coinnews
