module github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator

go 1.25.0

require (
	connectrpc.com/connect v1.20.0
	github.com/barebitcoin/btc-buf v0.0.0-20260808142039-a2f409838633
	github.com/btcsuite/btcd v0.25.0
	github.com/btcsuite/btcd/btcec/v2 v2.5.0
	github.com/btcsuite/btcd/btcutil v1.1.6
	github.com/btcsuite/btcd/btcutil/psbt v1.2.0
	github.com/btcsuite/btcd/chaincfg/chainhash v1.1.0
	github.com/fsnotify/fsnotify v1.9.0
	github.com/mattn/go-sqlite3 v1.14.45
	github.com/rs/zerolog v1.35.1
	github.com/samber/lo v1.53.0
	github.com/stretchr/testify v1.11.1
	github.com/tyler-smith/go-bip32 v1.0.0
	github.com/tyler-smith/go-bip39 v1.1.0
	github.com/urfave/cli/v2 v2.27.7
	golang.org/x/crypto v0.53.0
	golang.org/x/net v0.55.0
	google.golang.org/protobuf v1.36.11
)

require (
	github.com/btcsuite/btcd/address/v2 v2.0.0 // indirect
	github.com/btcsuite/btcd/btcutil/v2 v2.0.1 // indirect
	github.com/btcsuite/btcd/chaincfg/v2 v2.0.0 // indirect
	github.com/btcsuite/btcd/chainhash/v2 v2.0.0 // indirect
	github.com/btcsuite/btcd/wire/v2 v2.0.1 // indirect
	github.com/kcalvinalvin/anet v0.0.0-20251112173137-d8ddc1f6dbee // indirect
	github.com/tidwall/gjson v1.19.0 // indirect
	github.com/tidwall/match v1.1.1 // indirect
	github.com/tidwall/pretty v1.2.0 // indirect
)

require (
	connectrpc.com/grpchealth v1.5.0 // indirect
	connectrpc.com/grpcreflect v1.3.0 // indirect
	github.com/FactomProject/basen v0.0.0-20150613233007-fe3947df716e // indirect
	github.com/FactomProject/btcutilecc v0.0.0-20130527213604-d3a63a5752ec // indirect
	github.com/LayerTwo-Labs/sidesail/sqlitemigrate v0.0.0
	github.com/btcsuite/btclog v1.0.0 // indirect
	github.com/cpuguy83/go-md2man/v2 v2.0.7 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/decred/dcrd/crypto/blake256 v1.1.0 // indirect
	github.com/decred/dcrd/dcrec/secp256k1/v4 v4.4.0 // indirect
	github.com/gorilla/mux v1.8.1 // indirect
	github.com/mattn/go-colorable v0.1.14 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/oklog/ulid/v2 v2.1.2 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/russross/blackfriday/v2 v2.1.0 // indirect
	github.com/xrash/smetrics v0.0.0-20240521201337-686a1a2994c1 // indirect
	golang.org/x/exp v0.0.0-20260112195511-716be5621a96 // indirect
	golang.org/x/sys v0.46.0 // indirect
	golang.org/x/text v0.38.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
)

replace github.com/LayerTwo-Labs/sidesail/sqlitemigrate => ../sqlitemigrate
