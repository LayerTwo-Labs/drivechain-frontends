module github.com/LayerTwo-Labs/sidesail/drivechain-server

go 1.22.4

// This must be synced by what's in https://github.com/barebitcoin/btc-buf/blob/master/go.mod
// Obvs not ideal! Better to establish a full on fork?
replace github.com/btcsuite/btcd => github.com/barebitcoin/btcd v0.23.5-0.20240817180753-3e09d68ba0dd

require (
	connectrpc.com/connect v1.16.2
	github.com/barebitcoin/btc-buf v0.0.0-20240818094747-54d67edf29ad
	github.com/btcsuite/btcd/btcutil v1.1.5
	github.com/jessevdk/go-flags v1.6.1
	github.com/rs/zerolog v1.33.0
	github.com/samber/lo v1.47.0
	github.com/sourcegraph/conc v0.3.0
	github.com/tidwall/gjson v1.17.3
	golang.org/x/net v0.23.0
	google.golang.org/protobuf v1.34.1
)

require (
	connectrpc.com/grpchealth v1.3.0 // indirect
	connectrpc.com/grpcreflect v1.2.0 // indirect
	github.com/btcsuite/btcd v0.23.5-0.20231215221805-96c9fd8078fd // indirect
	github.com/btcsuite/btcd/btcec/v2 v2.3.2 // indirect
	github.com/btcsuite/btcd/chaincfg/chainhash v1.1.0 // indirect
	github.com/btcsuite/btclog v0.0.0-20170628155309-84c8d2346e9f // indirect
	github.com/btcsuite/go-socks v0.0.0-20170105172521-4720035b7bfd // indirect
	github.com/btcsuite/websocket v0.0.0-20150119174127-31079b680792 // indirect
	github.com/decred/dcrd/crypto/blake256 v1.0.1 // indirect
	github.com/decred/dcrd/dcrec/secp256k1/v4 v4.2.0 // indirect
	github.com/gorilla/mux v1.8.1 // indirect
	github.com/mattn/go-colorable v0.1.13 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/oklog/ulid/v2 v2.1.0 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.0 // indirect
	go.uber.org/atomic v1.7.0 // indirect
	go.uber.org/multierr v1.9.0 // indirect
	golang.org/x/crypto v0.21.0 // indirect
	golang.org/x/exp v0.0.0-20231226003508-02704c960a9b // indirect
	golang.org/x/sys v0.21.0 // indirect
	golang.org/x/text v0.16.0 // indirect
)
