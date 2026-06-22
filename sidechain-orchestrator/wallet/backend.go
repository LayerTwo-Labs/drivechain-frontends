package wallet

import (
	"context"
)

// Backend serves the wallets in wallet.json from some chain backend:
// balances, UTXOs, history, addresses, and signed sends. All methods take
// the orchestrator wallet ID; resolving it to backend-specific state is the
// backend's job. Implementations: CoreBackend (Bitcoin Core descriptor
// wallets); electrum/btcd backends slot in behind the same interface.
//
// Backends that sign in-process instead of delegating to a node build on
// the shared local primitives: DeriveBIP84Addresses (address derivation),
// BuildUnsignedTransaction (tx assembly), and SignTransactionLocal with a
// KeySource (P2WPKH/P2PKH signing). Type contracts for everything crossing
// this interface live in provider_types.go. Wiring happens at one place,
// cmd/orchestratord, by swapping the constructor.
type Backend interface {
	// Ensure makes walletID usable on the backend, creating backend state
	// if needed, and returns the backend's handle for it (Core: the Core
	// wallet name).
	Ensure(ctx context.Context, walletID string) (string, error)
	// EnsureAll syncs every backend-backed wallet; returns the count synced.
	EnsureAll(ctx context.Context) (int, error)

	// Balance returns confirmed and unconfirmed BTC.
	Balance(ctx context.Context, walletID string) (confirmed, unconfirmed float64, err error)
	ListUnspent(ctx context.Context, walletID string) ([]UTXO, error)
	ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error)
	ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error)
	ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error)
	GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error)
	// AddressHDPath returns the BIP32 derivation path of a wallet address.
	AddressHDPath(ctx context.Context, walletID, address string) (string, error)

	// NextReceiveAddress returns an unused receive address, minting one only
	// when every existing address has received funds.
	NextReceiveAddress(ctx context.Context, walletID string) (string, error)
	NextChangeAddress(ctx context.Context, walletID string) (string, error)

	// WatchKeys registers extra keys whose addresses the wallet must track
	// (BIP47 per-sender payment windows).
	WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error

	// Send pays req's destinations, handling coin selection, fees, change,
	// signing, and broadcast however the backend does it.
	Send(ctx context.Context, walletID string, req SendRequest) (string, error)
	SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error)
	BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error)

	Chain() ChainSource
}

// Bip47Backend is a Backend that can participate in BIP47. Everything the send
// path and inbound engine need is already on Backend (WatchKeys, the chain
// reads, signing); the one backend-specific operation is watching the wallet's
// own notification address. Core (descriptor import) and electrum (watch key)
// implement it; the enforcer does not, so it is simply not BIP47-capable. A new
// provider becomes BIP47-capable by implementing this one method.
type Bip47Backend interface {
	Backend
	// EnsureNotificationWatched makes the wallet track its own BIP47
	// notification address (the P2PKH for notifKey), rescanning history per
	// notifKey.RescanFrom so past notifications surface in ListTransactionsRange.
	// Idempotent.
	EnsureNotificationWatched(ctx context.Context, walletID string, notifKey WatchKey) error
}

// ChainSource is wallet-agnostic chain access shared by all backends.
type ChainSource interface {
	GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error)
	// Broadcast submits a raw tx to the network and returns its txid.
	Broadcast(ctx context.Context, rawHex string) (string, error)
}
