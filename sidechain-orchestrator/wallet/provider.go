package wallet

import (
	"context"
)

// Provider serves the wallets in wallet.json from some chain backend:
// balances, UTXOs, history, addresses, and signed sends. All methods take
// the orchestrator wallet ID; resolving it to backend-specific state is the
// provider's job. Implementations: CoreProvider (Bitcoin Core descriptor
// wallets); electrum/btcd providers slot in behind the same interface.
//
// Providers that sign in-process instead of delegating to a node build on
// the shared local primitives: DeriveBIP84Addresses (address derivation),
// BuildUnsignedTransaction (tx assembly), and SignTransactionLocal with a
// KeySource (P2WPKH/P2PKH signing). Type contracts for everything crossing
// this interface live in provider_types.go. Wiring happens at one place,
// cmd/orchestratord, by swapping the constructor.
type Provider interface {
	// Ensure makes walletID usable on the backend, creating backend state
	// if needed, and returns the provider's handle for it (Core: the Core
	// wallet name).
	Ensure(ctx context.Context, walletID string) (string, error)
	// EnsureAll syncs every provider-backed wallet; returns the count synced.
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

	SendToAddress(ctx context.Context, walletID, address string, amount float64, subtractFee bool) (string, error)
	SendMany(ctx context.Context, walletID string, amounts map[string]float64) (string, error)
	// FundTransaction completes a raw tx with wallet inputs and change.
	FundTransaction(ctx context.Context, walletID, rawHex string, opts FundOptions) (*FundRawTransactionResult, error)
	SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error)
	BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error)

	Chain() ChainSource
}

// ChainSource is wallet-agnostic chain access shared by all providers.
type ChainSource interface {
	GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error)
	// Broadcast submits a raw tx to the network and returns its txid.
	Broadcast(ctx context.Context, rawHex string) (string, error)
}
