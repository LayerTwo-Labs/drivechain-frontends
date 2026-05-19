// Copyright (c) 2014-2020 The btcsuite developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

package rpcclient

import (
	"context"
	"encoding/json"
	"strconv"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"

	"github.com/barebitcoin/btc-buf/rpcclient/btcjson"
)

// *****************************
// Transaction Listing Functions
// *****************************

// FutureGetTransactionResult is a future promise to deliver the result
// of a GetTransactionAsync or GetTransactionWatchOnlyAsync RPC invocation
// (or an applicable error).
type FutureGetTransactionResult chan *Response

// Receive waits for the Response promised by the future and returns detailed
// information about a wallet transaction.
func (r FutureGetTransactionResult) Receive() (*btcjson.GetTransactionResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a gettransaction result object
	var getTx btcjson.GetTransactionResult
	err = json.Unmarshal(res, &getTx)
	if err != nil {
		return nil, err
	}

	return &getTx, nil
}

// GetTransactionAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See GetTransaction for the blocking version and more details.
func (c *Client) GetTransactionAsync(ctx context.Context, txHash *chainhash.Hash) FutureGetTransactionResult {
	hash := ""
	if txHash != nil {
		hash = txHash.String()
	}

	cmd := btcjson.NewGetTransactionCmd(hash, nil)
	return c.SendCmd(ctx, cmd)
}

// GetTransaction returns detailed information about a wallet transaction.
//
// See GetRawTransaction to return the raw transaction instead.
func (c *Client) GetTransaction(ctx context.Context, txHash *chainhash.Hash) (*btcjson.GetTransactionResult, error) {
	return c.GetTransactionAsync(ctx, txHash).Receive()
}

// GetTransactionWatchOnlyAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See GetTransactionWatchOnly for the blocking version and more details.
func (c *Client) GetTransactionWatchOnlyAsync(ctx context.Context, txHash *chainhash.Hash, watchOnly bool) FutureGetTransactionResult {
	hash := ""
	if txHash != nil {
		hash = txHash.String()
	}

	cmd := btcjson.NewGetTransactionCmd(hash, &watchOnly)
	return c.SendCmd(ctx, cmd)
}

// GetTransactionWatchOnly returns detailed information about a wallet
// transaction, and allow including watch-only addresses in balance
// calculation and details.
func (c *Client) GetTransactionWatchOnly(ctx context.Context, txHash *chainhash.Hash, watchOnly bool) (*btcjson.GetTransactionResult, error) {
	return c.GetTransactionWatchOnlyAsync(ctx, txHash, watchOnly).Receive()
}

// FutureListTransactionsResult is a future promise to deliver the result of a
// ListTransactionsAsync, ListTransactionsCountAsync, or
// ListTransactionsCountFromAsync RPC invocation (or an applicable error).
type FutureListTransactionsResult chan *Response

// Receive waits for the Response promised by the future and returns a list of
// the most recent transactions.
func (r FutureListTransactionsResult) Receive() ([]btcjson.ListTransactionsResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as an array of listtransaction result objects.
	var transactions []btcjson.ListTransactionsResult
	err = json.Unmarshal(res, &transactions)
	if err != nil {
		return nil, err
	}

	return transactions, nil
}

// ListTransactionsAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See ListTransactions for the blocking version and more details.
func (c *Client) ListTransactionsAsync(ctx context.Context, account string) FutureListTransactionsResult {
	cmd := btcjson.NewListTransactionsCmd(&account, nil, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListTransactions returns a list of the most recent transactions.
//
// See the ListTransactionsCount and ListTransactionsCountFrom to control the
// number of transactions returned and starting point, respectively.
func (c *Client) ListTransactions(ctx context.Context, account string) ([]btcjson.ListTransactionsResult, error) {
	return c.ListTransactionsAsync(ctx, account).Receive()
}

// ListTransactionsCountAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListTransactionsCount for the blocking version and more details.
func (c *Client) ListTransactionsCountAsync(ctx context.Context, account string, count int) FutureListTransactionsResult {
	cmd := btcjson.NewListTransactionsCmd(&account, &count, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListTransactionsCount returns a list of the most recent transactions up
// to the passed count.
//
// See the ListTransactions and ListTransactionsCountFrom functions for
// different options.
func (c *Client) ListTransactionsCount(ctx context.Context, account string, count int) ([]btcjson.ListTransactionsResult, error) {
	return c.ListTransactionsCountAsync(ctx, account, count).Receive()
}

// ListTransactionsCountFromAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListTransactionsCountFrom for the blocking version and more details.
func (c *Client) ListTransactionsCountFromAsync(ctx context.Context, account string, count, from int) FutureListTransactionsResult {
	cmd := btcjson.NewListTransactionsCmd(&account, &count, &from, nil)
	return c.SendCmd(ctx, cmd)
}

// ListTransactionsCountFrom returns a list of the most recent transactions up
// to the passed count while skipping the first 'from' transactions.
//
// See the ListTransactions and ListTransactionsCount functions to use defaults.
func (c *Client) ListTransactionsCountFrom(ctx context.Context, account string, count, from int) ([]btcjson.ListTransactionsResult, error) {
	return c.ListTransactionsCountFromAsync(ctx, account, count, from).Receive()
}

// ListTransactionsCountFromWatchOnlyAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListTransactionsCountFromWatchOnly for the blocking version and more details.
func (c *Client) ListTransactionsCountFromWatchOnlyAsync(ctx context.Context, account string, count, from int, watchOnly bool) FutureListTransactionsResult {
	cmd := btcjson.NewListTransactionsCmd(&account, &count, &from, &watchOnly)
	return c.SendCmd(ctx, cmd)
}

// ListTransactionsCountFromWatchOnly returns a list of the most recent transactions up
// to the passed count while skipping the first 'from' transactions. It will include or
// exclude transactions from watch-only addresses based on the passed value for the watchOnly parameter
//
// See the ListTransactions and ListTransactionsCount functions to use defaults.
func (c *Client) ListTransactionsCountFromWatchOnly(ctx context.Context, account string, count, from int, watchOnly bool) ([]btcjson.ListTransactionsResult, error) {
	return c.ListTransactionsCountFromWatchOnlyAsync(ctx, account, count, from, watchOnly).Receive()
}

// FutureListUnspentResult is a future promise to deliver the result of a
// ListUnspentAsync, ListUnspentMinAsync, ListUnspentMinMaxAsync, or
// ListUnspentMinMaxAddressesAsync RPC invocation (or an applicable error).
type FutureListUnspentResult chan *Response

// Receive waits for the Response promised by the future and returns all
// unspent wallet transaction outputs returned by the RPC call.  If the
// future wac returned by a call to ListUnspentMinAsync, ListUnspentMinMaxAsync,
// or ListUnspentMinMaxAddressesAsync, the range may be limited by the
// parameters of the RPC invocation.
func (r FutureListUnspentResult) Receive() ([]btcjson.ListUnspentResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as an array of listunspent results.
	var unspent []btcjson.ListUnspentResult
	err = json.Unmarshal(res, &unspent)
	if err != nil {
		return nil, err
	}

	return unspent, nil
}

// ListUnspentAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function
// on the returned instance.
//
// See ListUnspent for the blocking version and more details.
func (c *Client) ListUnspentAsync(ctx context.Context) FutureListUnspentResult {
	cmd := btcjson.NewListUnspentCmd(nil, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListUnspentMinAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function
// on the returned instance.
//
// See ListUnspentMin for the blocking version and more details.
func (c *Client) ListUnspentMinAsync(ctx context.Context, minConf int) FutureListUnspentResult {
	cmd := btcjson.NewListUnspentCmd(&minConf, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListUnspentMinMaxAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function
// on the returned instance.
//
// See ListUnspentMinMax for the blocking version and more details.
func (c *Client) ListUnspentMinMaxAsync(ctx context.Context, minConf, maxConf int) FutureListUnspentResult {
	cmd := btcjson.NewListUnspentCmd(&minConf, &maxConf, nil)
	return c.SendCmd(ctx, cmd)
}

// ListUnspentMinMaxAddressesAsync returns an instance of a type that can be
// used to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListUnspentMinMaxAddresses for the blocking version and more details.
func (c *Client) ListUnspentMinMaxAddressesAsync(ctx context.Context, minConf, maxConf int, addrs []btcutil.Address) FutureListUnspentResult {
	addrStrs := make([]string, 0, len(addrs))
	for _, a := range addrs {
		addrStrs = append(addrStrs, a.EncodeAddress())
	}

	cmd := btcjson.NewListUnspentCmd(&minConf, &maxConf, &addrStrs)
	return c.SendCmd(ctx, cmd)
}

// ListUnspent returns all unspent transaction outputs known to a wallet, using
// the default number of minimum and maximum number of confirmations as a
// filter (1 and 999999, respectively).
func (c *Client) ListUnspent(ctx context.Context) ([]btcjson.ListUnspentResult, error) {
	return c.ListUnspentAsync(ctx).Receive()
}

// ListUnspentMin returns all unspent transaction outputs known to a wallet,
// using the specified number of minimum confirmations and default number of
// maximum confirmations (999999) as a filter.
func (c *Client) ListUnspentMin(ctx context.Context, minConf int) ([]btcjson.ListUnspentResult, error) {
	return c.ListUnspentMinAsync(ctx, minConf).Receive()
}

// ListUnspentMinMax returns all unspent transaction outputs known to a wallet,
// using the specified number of minimum and maximum number of confirmations as
// a filter.
func (c *Client) ListUnspentMinMax(ctx context.Context, minConf, maxConf int) ([]btcjson.ListUnspentResult, error) {
	return c.ListUnspentMinMaxAsync(ctx, minConf, maxConf).Receive()
}

// ListUnspentMinMaxAddresses returns all unspent transaction outputs that pay
// to any of specified addresses in a wallet using the specified number of
// minimum and maximum number of confirmations as a filter.
func (c *Client) ListUnspentMinMaxAddresses(ctx context.Context, minConf, maxConf int, addrs []btcutil.Address) ([]btcjson.ListUnspentResult, error) {
	return c.ListUnspentMinMaxAddressesAsync(ctx, minConf, maxConf, addrs).Receive()
}

// FutureListSinceBlockResult is a future promise to deliver the result of a
// ListSinceBlockAsync or ListSinceBlockMinConfAsync RPC invocation (or an
// applicable error).
type FutureListSinceBlockResult chan *Response

// Receive waits for the Response promised by the future and returns all
// transactions added in blocks since the specified block hash, or all
// transactions if it is nil.
func (r FutureListSinceBlockResult) Receive() (*btcjson.ListSinceBlockResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a listsinceblock result object.
	var listResult btcjson.ListSinceBlockResult
	err = json.Unmarshal(res, &listResult)
	if err != nil {
		return nil, err
	}

	return &listResult, nil
}

// ListSinceBlockAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See ListSinceBlock for the blocking version and more details.
func (c *Client) ListSinceBlockAsync(ctx context.Context, blockHash *chainhash.Hash) FutureListSinceBlockResult {
	var hash *string
	if blockHash != nil {
		hash = btcjson.String(blockHash.String())
	}

	cmd := btcjson.NewListSinceBlockCmd(hash, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListSinceBlock returns all transactions added in blocks since the specified
// block hash, or all transactions if it is nil, using the default number of
// minimum confirmations as a filter.
//
// See ListSinceBlockMinConf to override the minimum number of confirmations.
// See ListSinceBlockMinConfWatchOnly to override the minimum number of confirmations and watch only parameter.
func (c *Client) ListSinceBlock(ctx context.Context, blockHash *chainhash.Hash) (*btcjson.ListSinceBlockResult, error) {
	return c.ListSinceBlockAsync(ctx, blockHash).Receive()
}

// ListSinceBlockMinConfAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListSinceBlockMinConf for the blocking version and more details.
func (c *Client) ListSinceBlockMinConfAsync(ctx context.Context, blockHash *chainhash.Hash, minConfirms int) FutureListSinceBlockResult {
	var hash *string
	if blockHash != nil {
		hash = btcjson.String(blockHash.String())
	}

	cmd := btcjson.NewListSinceBlockCmd(hash, &minConfirms, nil)
	return c.SendCmd(ctx, cmd)
}

// ListSinceBlockMinConf returns all transactions added in blocks since the
// specified block hash, or all transactions if it is nil, using the specified
// number of minimum confirmations as a filter.
//
// See ListSinceBlock to use the default minimum number of confirmations.
func (c *Client) ListSinceBlockMinConf(ctx context.Context, blockHash *chainhash.Hash, minConfirms int) (*btcjson.ListSinceBlockResult, error) {
	return c.ListSinceBlockMinConfAsync(ctx, blockHash, minConfirms).Receive()
}

// ListSinceBlockMinConfWatchOnlyAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListSinceBlockMinConfWatchOnly for the blocking version and more details.
func (c *Client) ListSinceBlockMinConfWatchOnlyAsync(ctx context.Context, blockHash *chainhash.Hash, minConfirms int, watchOnly bool) FutureListSinceBlockResult {
	var hash *string
	if blockHash != nil {
		hash = btcjson.String(blockHash.String())
	}

	cmd := btcjson.NewListSinceBlockCmd(hash, &minConfirms, &watchOnly)
	return c.SendCmd(ctx, cmd)
}

// ListSinceBlockMinConfWatchOnly returns all transactions added in blocks since the
// specified block hash, or all transactions if it is nil, using the specified
// number of minimum confirmations as a filter.
//
// See ListSinceBlock to use the default minimum number of confirmations and default watch only parameter.
func (c *Client) ListSinceBlockMinConfWatchOnly(ctx context.Context, blockHash *chainhash.Hash, minConfirms int, watchOnly bool) (*btcjson.ListSinceBlockResult, error) {
	return c.ListSinceBlockMinConfWatchOnlyAsync(ctx, blockHash, minConfirms, watchOnly).Receive()
}

// **************************
// Transaction Send Functions
// **************************

// FutureLockUnspentResult is a future promise to deliver the error result of a
// LockUnspentAsync RPC invocation.
type FutureLockUnspentResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of locking or unlocking the unspent output(s).
func (r FutureLockUnspentResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// LockUnspentAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See LockUnspent for the blocking version and more details.
func (c *Client) LockUnspentAsync(ctx context.Context, unlock bool, ops []*wire.OutPoint) FutureLockUnspentResult {
	outputs := make([]btcjson.TransactionInput, len(ops))
	for i, op := range ops {
		outputs[i] = btcjson.TransactionInput{
			Txid: op.Hash.String(),
			Vout: op.Index,
		}
	}
	cmd := btcjson.NewLockUnspentCmd(unlock, outputs)
	return c.SendCmd(ctx, cmd)
}

// LockUnspent marks outputs as locked or unlocked, depending on the value of
// the unlock bool.  When locked, the unspent output will not be selected as
// input for newly created, non-raw transactions, and will not be returned in
// future ListUnspent results, until the output is marked unlocked again.
//
// If unlock is false, each outpoint in ops will be marked locked.  If unlocked
// is true and specific outputs are specified in ops (len != 0), exactly those
// outputs will be marked unlocked.  If unlocked is true and no outpoints are
// specified, all previous locked outputs are marked unlocked.
//
// The locked or unlocked state of outputs are not written to disk and after
// restarting a wallet process, this data will be reset (every output unlocked).
//
// NOTE: While this method would be a bit more readable if the unlock bool was
// reversed (that is, LockUnspent(true, ...) locked the outputs), it has been
// left as unlock to keep compatibility with the reference client API and to
// avoid confusion for those who are already familiar with the lockunspent RPC.
func (c *Client) LockUnspent(ctx context.Context, unlock bool, ops []*wire.OutPoint) error {
	return c.LockUnspentAsync(ctx, unlock, ops).Receive()
}

// FutureListLockUnspentResult is a future promise to deliver the result of a
// ListLockUnspentAsync RPC invocation (or an applicable error).
type FutureListLockUnspentResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of all currently locked unspent outputs.
func (r FutureListLockUnspentResult) Receive() ([]*wire.OutPoint, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal as an array of transaction inputs.
	var inputs []btcjson.TransactionInput
	err = json.Unmarshal(res, &inputs)
	if err != nil {
		return nil, err
	}

	// Create a slice of outpoints from the transaction input structs.
	ops := make([]*wire.OutPoint, len(inputs))
	for i, input := range inputs {
		sha, err := chainhash.NewHashFromStr(input.Txid)
		if err != nil {
			return nil, err
		}
		ops[i] = wire.NewOutPoint(sha, input.Vout)
	}

	return ops, nil
}

// ListLockUnspentAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See ListLockUnspent for the blocking version and more details.
func (c *Client) ListLockUnspentAsync(ctx context.Context) FutureListLockUnspentResult {
	cmd := btcjson.NewListLockUnspentCmd()
	return c.SendCmd(ctx, cmd)
}

// ListLockUnspent returns a slice of outpoints for all unspent outputs marked
// as locked by a wallet.  Unspent outputs may be marked locked using
// LockOutput.
func (c *Client) ListLockUnspent(ctx context.Context) ([]*wire.OutPoint, error) {
	return c.ListLockUnspentAsync(ctx).Receive()
}

// FutureSetTxFeeResult is a future promise to deliver the result of a
// SetTxFeeAsync RPC invocation (or an applicable error).
type FutureSetTxFeeResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of setting an optional transaction fee per KB that helps ensure transactions
// are processed quickly.  Most transaction are 1KB.
func (r FutureSetTxFeeResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// SetTxFeeAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SetTxFee for the blocking version and more details.
func (c *Client) SetTxFeeAsync(ctx context.Context, fee btcutil.Amount) FutureSetTxFeeResult {
	cmd := btcjson.NewSetTxFeeCmd(fee.ToBTC())
	return c.SendCmd(ctx, cmd)
}

// SetTxFee sets an optional transaction fee per KB that helps ensure
// transactions are processed quickly.  Most transaction are 1KB.
func (c *Client) SetTxFee(ctx context.Context, fee btcutil.Amount) error {
	return c.SetTxFeeAsync(ctx, fee).Receive()
}

// FutureSendResult is a future promise to deliver the result of a
// SendAsync RPC invocation (or an applicable error).
type FutureSendResult chan *Response

func (r FutureSendResult) Receive() (*btcjson.SendResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var out btcjson.SendResult
	if err := json.Unmarshal(res, &out); err != nil {
		return nil, err
	}

	return &out, nil
}

// WalletSend sends a transaction. This corresponds to the `send`
// Bitcoin Core RPC. This function is not named Send, because that
// collides with another exported symbol in this package.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) WalletSend(
	ctx context.Context, outputs []btcjson.SendDestination, opts ...WalletSendOpt,
) (*btcjson.SendResult, error) {
	return c.WalletSendAsync(ctx, outputs, opts...).Receive()
}

// SendAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See Send for the blocking version and more details.
func (c *Client) WalletSendAsync(
	ctx context.Context, outputs []btcjson.SendDestination, opts ...WalletSendOpt,
) FutureSendResult {
	mode := btcjson.EstimateModeUnset
	cmd := &btcjson.SendCmd{
		Outputs:      outputs,
		EstimateMode: &mode,
		Options:      &btcjson.SendOptions{},
	}

	for _, fn := range opts {
		fn(cmd)
	}

	// Sanity check all the outputs
	for _, out := range outputs {
		switch {
		// Sending money
		case out.Data == nil && (out.Address != "" && out.Amount != 0):

		// Doing an OP_RETURN
		case len(out.Data) != 0 && (out.Address == "" && out.Amount == 0):

		default:
			panic("programmer error: must EITHER set data OR address + amount")
		}
	}

	return c.SendCmd(ctx, cmd)
}

type WalletSendOpt func(*btcjson.SendCmd)

func WithWalletSendAddToWallet(add bool) WalletSendOpt {
	return func(sc *btcjson.SendCmd) { sc.Options.AddToWallet = &add }
}

// Specify a fee rate in sat/vB.
func WithWalletSendFeeRate(rate float64) WalletSendOpt {
	return func(sc *btcjson.SendCmd) { sc.FeeRate = &rate }
}

func WithWalletSendConfirmationTarget(target int) WalletSendOpt {
	return func(cmd *btcjson.SendCmd) {
		cmd.ConfTarget = &target
	}
}

func WithWalletSendIncludeUnsafe() WalletSendOpt {
	return func(cmd *btcjson.SendCmd) {
		cmd.Options.IncludeUnsafe = btcjson.Bool(true)
	}
}

func WithWalletSendSubtractFeeFromOutputs(outputs []int) WalletSendOpt {
	return func(cmd *btcjson.SendCmd) {
		cmd.Options.SubtractFeeFromOutputs = outputs
	}
}

// FutureSendToAddressResult is a future promise to deliver the result of a
// SendToAddressAsync RPC invocation (or an applicable error).
type FutureSendToAddressResult chan *Response

// Receive waits for the Response promised by the future and returns the hash
// of the transaction sending the passed amount to the given address.
func (r FutureSendToAddressResult) Receive() (*chainhash.Hash, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var txHash string
	err = json.Unmarshal(res, &txHash)
	if err != nil {
		return nil, err
	}

	return chainhash.NewHashFromStr(txHash)
}

// SendToAddressAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SendToAddress for the blocking version and more details.
func (c *Client) SendToAddressAsync(ctx context.Context, address btcutil.Address, amount btcutil.Amount) FutureSendToAddressResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewSendToAddressCmd(addr, amount.ToBTC(), nil, nil)
	return c.SendCmd(ctx, cmd)
}

// SendToAddress sends the passed amount to the given address.
//
// See SendToAddressComment to associate comments with the transaction in the
// wallet.  The comments are not part of the transaction and are only internal
// to the wallet.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendToAddress(ctx context.Context, address btcutil.Address, amount btcutil.Amount) (*chainhash.Hash, error) {
	return c.SendToAddressAsync(ctx, address, amount).Receive()
}

// SendToAddressCommentAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See SendToAddressComment for the blocking version and more details.
func (c *Client) SendToAddressCommentAsync(ctx context.Context, address btcutil.Address,
	amount btcutil.Amount, comment,
	commentTo string,
) FutureSendToAddressResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewSendToAddressCmd(addr, amount.ToBTC(), &comment,
		&commentTo)
	return c.SendCmd(ctx, cmd)
}

// SendToAddressComment sends the passed amount to the given address and stores
// the provided comment and comment to in the wallet.  The comment parameter is
// intended to be used for the purpose of the transaction while the commentTo
// parameter is intended to be used for who the transaction is being sent to.
//
// The comments are not part of the transaction and are only internal
// to the wallet.
//
// See SendToAddress to avoid using comments.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendToAddressComment(ctx context.Context, address btcutil.Address, amount btcutil.Amount, comment, commentTo string) (*chainhash.Hash, error) {
	return c.SendToAddressCommentAsync(ctx, address, amount, comment,
		commentTo).Receive()
}

// FutureSendFromResult is a future promise to deliver the result of a
// SendFromAsync, SendFromMinConfAsync, or SendFromCommentAsync RPC invocation
// (or an applicable error).
type FutureSendFromResult chan *Response

// Receive waits for the Response promised by the future and returns the hash
// of the transaction sending amount to the given address using the provided
// account as a source of funds.
func (r FutureSendFromResult) Receive() (*chainhash.Hash, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var txHash string
	err = json.Unmarshal(res, &txHash)
	if err != nil {
		return nil, err
	}

	return chainhash.NewHashFromStr(txHash)
}

// SendFromAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SendFrom for the blocking version and more details.
func (c *Client) SendFromAsync(ctx context.Context, fromAccount string, toAddress btcutil.Address, amount btcutil.Amount) FutureSendFromResult {
	addr := toAddress.EncodeAddress()
	cmd := btcjson.NewSendFromCmd(fromAccount, addr, amount.ToBTC(), nil,
		nil, nil)
	return c.SendCmd(ctx, cmd)
}

// SendFrom sends the passed amount to the given address using the provided
// account as a source of funds.  Only funds with the default number of minimum
// confirmations will be used.
//
// See SendFromMinConf and SendFromComment for different options.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendFrom(ctx context.Context, fromAccount string, toAddress btcutil.Address, amount btcutil.Amount) (*chainhash.Hash, error) {
	return c.SendFromAsync(ctx, fromAccount, toAddress, amount).Receive()
}

// SendFromMinConfAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See SendFromMinConf for the blocking version and more details.
func (c *Client) SendFromMinConfAsync(ctx context.Context, fromAccount string, toAddress btcutil.Address, amount btcutil.Amount, minConfirms int) FutureSendFromResult {
	addr := toAddress.EncodeAddress()
	cmd := btcjson.NewSendFromCmd(fromAccount, addr, amount.ToBTC(),
		&minConfirms, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// SendFromMinConf sends the passed amount to the given address using the
// provided account as a source of funds.  Only funds with the passed number of
// minimum confirmations will be used.
//
// See SendFrom to use the default number of minimum confirmations and
// SendFromComment for additional options.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendFromMinConf(ctx context.Context, fromAccount string, toAddress btcutil.Address, amount btcutil.Amount, minConfirms int) (*chainhash.Hash, error) {
	return c.SendFromMinConfAsync(ctx, fromAccount, toAddress, amount,
		minConfirms).Receive()
}

// SendFromCommentAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See SendFromComment for the blocking version and more details.
func (c *Client) SendFromCommentAsync(ctx context.Context, fromAccount string,
	toAddress btcutil.Address, amount btcutil.Amount, minConfirms int,
	comment, commentTo string,
) FutureSendFromResult {
	addr := toAddress.EncodeAddress()
	cmd := btcjson.NewSendFromCmd(fromAccount, addr, amount.ToBTC(),
		&minConfirms, &comment, &commentTo)
	return c.SendCmd(ctx, cmd)
}

// SendFromComment sends the passed amount to the given address using the
// provided account as a source of funds and stores the provided comment and
// comment to in the wallet.  The comment parameter is intended to be used for
// the purpose of the transaction while the commentTo parameter is intended to
// be used for who the transaction is being sent to.  Only funds with the passed
// number of minimum confirmations will be used.
//
// See SendFrom and SendFromMinConf to use defaults.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendFromComment(ctx context.Context, fromAccount string, toAddress btcutil.Address,
	amount btcutil.Amount, minConfirms int,
	comment, commentTo string,
) (*chainhash.Hash, error) {
	return c.SendFromCommentAsync(ctx, fromAccount, toAddress, amount,
		minConfirms, comment, commentTo).Receive()
}

// FutureSendManyResult is a future promise to deliver the result of a
// SendManyAsync, SendManyMinConfAsync, or SendManyCommentAsync RPC invocation
// (or an applicable error).
type FutureSendManyResult chan *Response

// Receive waits for the Response promised by the future and returns the hash
// of the transaction sending multiple amounts to multiple addresses using the
// provided account as a source of funds.
func (r FutureSendManyResult) Receive() (*chainhash.Hash, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmashal result as a string.
	var txHash string
	err = json.Unmarshal(res, &txHash)
	if err != nil {
		return nil, err
	}

	return chainhash.NewHashFromStr(txHash)
}

// SendManyAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SendMany for the blocking version and more details.
func (c *Client) SendManyAsync(ctx context.Context, fromAccount string, amounts map[btcutil.Address]btcutil.Amount) FutureSendManyResult {
	convertedAmounts := make(map[string]float64, len(amounts))
	for addr, amount := range amounts {
		convertedAmounts[addr.EncodeAddress()] = amount.ToBTC()
	}
	cmd := btcjson.NewSendManyCmd(fromAccount, convertedAmounts, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// SendMany sends multiple amounts to multiple addresses using the provided
// account as a source of funds in a single transaction.  Only funds with the
// default number of minimum confirmations will be used.
//
// See SendManyMinConf and SendManyComment for different options.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendMany(ctx context.Context, fromAccount string, amounts map[btcutil.Address]btcutil.Amount) (*chainhash.Hash, error) {
	return c.SendManyAsync(ctx, fromAccount, amounts).Receive()
}

// SendManyMinConfAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See SendManyMinConf for the blocking version and more details.
func (c *Client) SendManyMinConfAsync(ctx context.Context, fromAccount string,
	amounts map[btcutil.Address]btcutil.Amount,
	minConfirms int,
) FutureSendManyResult {
	convertedAmounts := make(map[string]float64, len(amounts))
	for addr, amount := range amounts {
		convertedAmounts[addr.EncodeAddress()] = amount.ToBTC()
	}
	cmd := btcjson.NewSendManyCmd(fromAccount, convertedAmounts,
		&minConfirms, nil)
	return c.SendCmd(ctx, cmd)
}

// SendManyMinConf sends multiple amounts to multiple addresses using the
// provided account as a source of funds in a single transaction.  Only funds
// with the passed number of minimum confirmations will be used.
//
// See SendMany to use the default number of minimum confirmations and
// SendManyComment for additional options.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendManyMinConf(ctx context.Context, fromAccount string,
	amounts map[btcutil.Address]btcutil.Amount,
	minConfirms int,
) (*chainhash.Hash, error) {
	return c.SendManyMinConfAsync(ctx, fromAccount, amounts, minConfirms).Receive()
}

// SendManyCommentAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See SendManyComment for the blocking version and more details.
func (c *Client) SendManyCommentAsync(ctx context.Context, fromAccount string,
	amounts map[btcutil.Address]btcutil.Amount, minConfirms int,
	comment string,
) FutureSendManyResult {
	convertedAmounts := make(map[string]float64, len(amounts))
	for addr, amount := range amounts {
		convertedAmounts[addr.EncodeAddress()] = amount.ToBTC()
	}
	cmd := btcjson.NewSendManyCmd(fromAccount, convertedAmounts,
		&minConfirms, &comment)
	return c.SendCmd(ctx, cmd)
}

// SendManyComment sends multiple amounts to multiple addresses using the
// provided account as a source of funds in a single transaction and stores the
// provided comment in the wallet.  The comment parameter is intended to be used
// for the purpose of the transaction   Only funds with the passed number of
// minimum confirmations will be used.
//
// See SendMany and SendManyMinConf to use defaults.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SendManyComment(ctx context.Context, fromAccount string,
	amounts map[btcutil.Address]btcutil.Amount, minConfirms int,
	comment string,
) (*chainhash.Hash, error) {
	return c.SendManyCommentAsync(ctx, fromAccount, amounts, minConfirms,
		comment).Receive()
}

// *************************
// Address/Account Functions
// *************************

// FutureAddMultisigAddressResult is a future promise to deliver the result of a
// AddMultisigAddressAsync RPC invocation (or an applicable error).
type FutureAddMultisigAddressResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns the
// multisignature address that requires the specified number of signatures for
// the provided addresses.
func (r FutureAddMultisigAddressResult) Receive() (btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var addr string
	err = json.Unmarshal(res, &addr)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeAddress(addr, r.network)
}

// AddMultisigAddressAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See AddMultisigAddress for the blocking version and more details.
func (c *Client) AddMultisigAddressAsync(ctx context.Context, requiredSigs int, addresses []btcutil.Address, account string) FutureAddMultisigAddressResult {
	addrs := make([]string, 0, len(addresses))
	for _, addr := range addresses {
		addrs = append(addrs, addr.String())
	}

	cmd := btcjson.NewAddMultisigAddressCmd(requiredSigs, addrs, &account)
	result := FutureAddMultisigAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// AddMultisigAddress adds a multisignature address that requires the specified
// number of signatures for the provided addresses to the wallet.
func (c *Client) AddMultisigAddress(ctx context.Context, requiredSigs int, addresses []btcutil.Address, account string) (btcutil.Address, error) {
	return c.AddMultisigAddressAsync(ctx, requiredSigs, addresses, account).Receive()
}

// FutureCreateMultisigResult is a future promise to deliver the result of a
// CreateMultisigAsync RPC invocation (or an applicable error).
type FutureCreateMultisigResult chan *Response

// Receive waits for the Response promised by the future and returns the
// multisignature address and script needed to redeem it.
func (r FutureCreateMultisigResult) Receive() (*btcjson.CreateMultiSigResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a createmultisig result object.
	var multisigRes btcjson.CreateMultiSigResult
	err = json.Unmarshal(res, &multisigRes)
	if err != nil {
		return nil, err
	}

	return &multisigRes, nil
}

// CreateMultisigAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See CreateMultisig for the blocking version and more details.
func (c *Client) CreateMultisigAsync(ctx context.Context, requiredSigs int, addresses []btcutil.Address) FutureCreateMultisigResult {
	addrs := make([]string, 0, len(addresses))
	for _, addr := range addresses {
		addrs = append(addrs, addr.String())
	}

	cmd := btcjson.NewCreateMultisigCmd(requiredSigs, addrs)
	return c.SendCmd(ctx, cmd)
}

// CreateMultisig creates a multisignature address that requires the specified
// number of signatures for the provided addresses and returns the
// multisignature address and script needed to redeem it.
func (c *Client) CreateMultisig(ctx context.Context, requiredSigs int, addresses []btcutil.Address) (*btcjson.CreateMultiSigResult, error) {
	return c.CreateMultisigAsync(ctx, requiredSigs, addresses).Receive()
}

// FutureCreateNewAccountResult is a future promise to deliver the result of a
// CreateNewAccountAsync RPC invocation (or an applicable error).
type FutureCreateNewAccountResult chan *Response

// Receive waits for the Response promised by the future and returns the
// result of creating new account.
func (r FutureCreateNewAccountResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// CreateNewAccountAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See CreateNewAccount for the blocking version and more details.
func (c *Client) CreateNewAccountAsync(ctx context.Context, account string) FutureCreateNewAccountResult {
	cmd := btcjson.NewCreateNewAccountCmd(account)
	return c.SendCmd(ctx, cmd)
}

// CreateNewAccount creates a new wallet account.
func (c *Client) CreateNewAccount(ctx context.Context, account string) error {
	return c.CreateNewAccountAsync(ctx, account).Receive()
}

// FutureCreateWalletResult is a future promise to deliver the result of a
// CreateWalletAsync RPC invocation (or an applicable error).
type FutureCreateWalletResult chan *Response

// Receive waits for the Response promised by the future and returns the
// result of creating a new wallet.
func (r FutureCreateWalletResult) Receive() (*btcjson.CreateWalletResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var createWalletResult btcjson.CreateWalletResult
	err = json.Unmarshal(res, &createWalletResult)
	if err != nil {
		return nil, err
	}
	return &createWalletResult, nil
}

// CreateWalletOpt defines a functional-option to be used with CreateWallet
// method.
type CreateWalletOpt func(*btcjson.CreateWalletCmd)

// WithCreateWalletDisablePrivateKeys disables the possibility of private keys
// to be used with a wallet created using the CreateWallet method. Using this
// option will make the wallet watch-only.
func WithCreateWalletDisablePrivateKeys() CreateWalletOpt {
	return func(c *btcjson.CreateWalletCmd) {
		c.DisablePrivateKeys = btcjson.Bool(true)
	}
}

// WithCreateWalletBlank specifies creation of a blank wallet.
func WithCreateWalletBlank() CreateWalletOpt {
	return func(c *btcjson.CreateWalletCmd) {
		c.Blank = btcjson.Bool(true)
	}
}

// WithCreateWalletPassphrase specifies a passphrase to encrypt the wallet
// with.
func WithCreateWalletPassphrase(value string) CreateWalletOpt {
	return func(c *btcjson.CreateWalletCmd) {
		c.Passphrase = btcjson.String(value)
	}
}

// WithCreateWalletAvoidReuse specifies keeping track of coin reuse, and
// treat dirty and clean coins differently with privacy considerations in mind.
func WithCreateWalletAvoidReuse() CreateWalletOpt {
	return func(c *btcjson.CreateWalletCmd) {
		c.AvoidReuse = btcjson.Bool(true)
	}
}

// CreateWalletAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See CreateWallet for the blocking version and more details.
func (c *Client) CreateWalletAsync(ctx context.Context, name string, opts ...CreateWalletOpt) FutureCreateWalletResult {
	cmd := btcjson.NewCreateWalletCmd(name, nil, nil, nil, nil)

	// Apply each specified option to mutate the default command.
	for _, opt := range opts {
		opt(cmd)
	}

	return c.SendCmd(ctx, cmd)
}

// CreateWallet creates a new wallet account, with the possibility to use
// private keys.
//
// Optional parameters can be specified using functional-options pattern. The
// following functions are available:
//   - WithCreateWalletDisablePrivateKeys
//   - WithCreateWalletBlank
//   - WithCreateWalletPassphrase
//   - WithCreateWalletAvoidReuse
func (c *Client) CreateWallet(ctx context.Context, name string, opts ...CreateWalletOpt) (*btcjson.CreateWalletResult, error) {
	return c.CreateWalletAsync(ctx, name, opts...).Receive()
}

// FutureGetAddressInfoResult is a future promise to deliver the result of an
// GetAddressInfoAsync RPC invocation (or an applicable error).
type FutureGetAddressInfoResult chan *Response

// Receive waits for the Response promised by the future and returns the information
// about the given bitcoin address.
func (r FutureGetAddressInfoResult) Receive() (*btcjson.GetAddressInfoResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var getAddressInfoResult btcjson.GetAddressInfoResult
	err = json.Unmarshal(res, &getAddressInfoResult)
	if err != nil {
		return nil, err
	}
	return &getAddressInfoResult, nil
}

// GetAddressInfoAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetAddressInfo for the blocking version and more details.
func (c *Client) GetAddressInfoAsync(ctx context.Context, address string) FutureGetAddressInfoResult {
	cmd := btcjson.NewGetAddressInfoCmd(address)
	return c.SendCmd(ctx, cmd)
}

// GetAddressInfo returns information about the given bitcoin address.
func (c *Client) GetAddressInfo(ctx context.Context, address string) (*btcjson.GetAddressInfoResult, error) {
	return c.GetAddressInfoAsync(ctx, address).Receive()
}

// FutureGetNewAddressResult is a future promise to deliver the result of a
// GetNewAddressAsync RPC invocation (or an applicable error).
type FutureGetNewAddressResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns a new
// address.
func (r FutureGetNewAddressResult) Receive() (btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var addr string
	err = json.Unmarshal(res, &addr)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeAddress(addr, r.network)
}

// GetNewAddressAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetNewAddress for the blocking version and more details.
func (c *Client) GetNewAddressAsync(ctx context.Context, account string) FutureGetNewAddressResult {
	cmd := btcjson.NewGetNewAddressCmd(&account, nil)
	result := FutureGetNewAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetNewAddress returns a new address, and decodes based on the client's
// chain params.
func (c *Client) GetNewAddress(ctx context.Context, account string) (btcutil.Address, error) {
	return c.GetNewAddressAsync(ctx, account).Receive()
}

// GetNewAddressTypeAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See GetNewAddressType for the blocking version and more details.
func (c *Client) GetNewAddressTypeAsync(ctx context.Context, account, addrType string) FutureGetNewAddressResult {
	cmd := btcjson.NewGetNewAddressCmd(&account, &addrType)
	result := FutureGetNewAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetNewAddressType returns a new address, and decodes based on the client's
// chain params.
func (c *Client) GetNewAddressType(ctx context.Context, account, addrType string) (btcutil.Address, error) {
	return c.GetNewAddressTypeAsync(ctx, account, addrType).Receive()
}

// FutureGetRawChangeAddressResult is a future promise to deliver the result of
// a GetRawChangeAddressAsync RPC invocation (or an applicable error).
type FutureGetRawChangeAddressResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns a new
// address for receiving change that will be associated with the provided
// account.  Note that this is only for raw transactions and NOT for normal use.
func (r FutureGetRawChangeAddressResult) Receive() (btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var addr string
	err = json.Unmarshal(res, &addr)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeAddress(addr, r.network)
}

// GetRawChangeAddressAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetRawChangeAddress for the blocking version and more details.
func (c *Client) GetRawChangeAddressAsync(ctx context.Context, account string) FutureGetRawChangeAddressResult {
	cmd := btcjson.NewGetRawChangeAddressCmd(&account, nil)
	result := FutureGetRawChangeAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetRawChangeAddress returns a new address for receiving change that will be
// associated with the provided account.  Note that this is only for raw
// transactions and NOT for normal use.
func (c *Client) GetRawChangeAddress(ctx context.Context, account string) (btcutil.Address, error) {
	return c.GetRawChangeAddressAsync(ctx, account).Receive()
}

// GetRawChangeAddressTypeAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetRawChangeAddressType for the blocking version and more details.
func (c *Client) GetRawChangeAddressTypeAsync(ctx context.Context, account, addrType string) FutureGetRawChangeAddressResult {
	cmd := btcjson.NewGetRawChangeAddressCmd(&account, &addrType)
	result := FutureGetRawChangeAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetRawChangeAddressType returns a new address for receiving change that will
// be associated with the provided account.  Note that this is only for raw
// transactions and NOT for normal use.
func (c *Client) GetRawChangeAddressType(ctx context.Context, account, addrType string) (btcutil.Address, error) {
	return c.GetRawChangeAddressTypeAsync(ctx, account, addrType).Receive()
}

// FutureAddWitnessAddressResult is a future promise to deliver the result of
// a AddWitnessAddressAsync RPC invocation (or an applicable error).
type FutureAddWitnessAddressResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns the new
// address.
func (r FutureAddWitnessAddressResult) Receive() (btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var addr string
	err = json.Unmarshal(res, &addr)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeAddress(addr, r.network)
}

// AddWitnessAddressAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See AddWitnessAddress for the blocking version and more details.
func (c *Client) AddWitnessAddressAsync(ctx context.Context, address string) FutureAddWitnessAddressResult {
	cmd := btcjson.NewAddWitnessAddressCmd(address)
	response := FutureAddWitnessAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return response
}

// AddWitnessAddress adds a witness address for a script and returns the new
// address (P2SH of the witness script).
func (c *Client) AddWitnessAddress(ctx context.Context, address string) (btcutil.Address, error) {
	return c.AddWitnessAddressAsync(ctx, address).Receive()
}

// FutureGetAccountAddressResult is a future promise to deliver the result of a
// GetAccountAddressAsync RPC invocation (or an applicable error).
type FutureGetAccountAddressResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns the current
// Bitcoin address for receiving payments to the specified account.
func (r FutureGetAccountAddressResult) Receive() (btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var addr string
	err = json.Unmarshal(res, &addr)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeAddress(addr, r.network)
}

// GetAccountAddressAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See GetAccountAddress for the blocking version and more details.
func (c *Client) GetAccountAddressAsync(ctx context.Context, account string) FutureGetAccountAddressResult {
	cmd := btcjson.NewGetAccountAddressCmd(account)
	result := FutureGetAccountAddressResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetAccountAddress returns the current Bitcoin address for receiving payments
// to the specified account.
func (c *Client) GetAccountAddress(ctx context.Context, account string) (btcutil.Address, error) {
	return c.GetAccountAddressAsync(ctx, account).Receive()
}

// FutureGetAccountResult is a future promise to deliver the result of a
// GetAccountAsync RPC invocation (or an applicable error).
type FutureGetAccountResult chan *Response

// Receive waits for the Response promised by the future and returns the account
// associated with the passed address.
func (r FutureGetAccountResult) Receive() (string, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return "", err
	}

	// Unmarshal result as a string.
	var account string
	err = json.Unmarshal(res, &account)
	if err != nil {
		return "", err
	}

	return account, nil
}

// GetAccountAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetAccount for the blocking version and more details.
func (c *Client) GetAccountAsync(ctx context.Context, address btcutil.Address) FutureGetAccountResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewGetAccountCmd(addr)
	return c.SendCmd(ctx, cmd)
}

// GetAccount returns the account associated with the passed address.
func (c *Client) GetAccount(ctx context.Context, address btcutil.Address) (string, error) {
	return c.GetAccountAsync(ctx, address).Receive()
}

// FutureSetAccountResult is a future promise to deliver the result of a
// SetAccountAsync RPC invocation (or an applicable error).
type FutureSetAccountResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of setting the account to be associated with the passed address.
func (r FutureSetAccountResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// SetAccountAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SetAccount for the blocking version and more details.
func (c *Client) SetAccountAsync(ctx context.Context, address btcutil.Address, account string) FutureSetAccountResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewSetAccountCmd(addr, account)
	return c.SendCmd(ctx, cmd)
}

// SetAccount sets the account associated with the passed address.
func (c *Client) SetAccount(ctx context.Context, address btcutil.Address, account string) error {
	return c.SetAccountAsync(ctx, address, account).Receive()
}

// FutureGetAddressesByAccountResult is a future promise to deliver the result
// of a GetAddressesByAccountAsync RPC invocation (or an applicable error).
type FutureGetAddressesByAccountResult struct {
	responseChannel chan *Response
	network         *chaincfg.Params
}

// Receive waits for the Response promised by the future and returns the list of
// addresses associated with the passed account.
func (r FutureGetAddressesByAccountResult) Receive() ([]btcutil.Address, error) {
	res, err := ReceiveFuture(r.responseChannel)
	if err != nil {
		return nil, err
	}

	// Unmashal result as an array of string.
	var addrStrings []string
	err = json.Unmarshal(res, &addrStrings)
	if err != nil {
		return nil, err
	}

	addresses := make([]btcutil.Address, len(addrStrings))
	for i, addrString := range addrStrings {
		addresses[i], err = btcutil.DecodeAddress(addrString, r.network)
		if err != nil {
			return nil, err
		}
	}

	return addresses, nil
}

// GetAddressesByAccountAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetAddressesByAccount for the blocking version and more details.
func (c *Client) GetAddressesByAccountAsync(ctx context.Context, account string) FutureGetAddressesByAccountResult {
	cmd := btcjson.NewGetAddressesByAccountCmd(account)
	result := FutureGetAddressesByAccountResult{
		network:         c.chainParams,
		responseChannel: c.SendCmd(ctx, cmd),
	}
	return result
}

// GetAddressesByAccount returns the list of addresses associated with the
// passed account.
func (c *Client) GetAddressesByAccount(ctx context.Context, account string) ([]btcutil.Address, error) {
	return c.GetAddressesByAccountAsync(ctx, account).Receive()
}

// FutureMoveResult is a future promise to deliver the result of a MoveAsync,
// MoveMinConfAsync, or MoveCommentAsync RPC invocation (or an applicable
// error).
type FutureMoveResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of the move operation.
func (r FutureMoveResult) Receive() (bool, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return false, err
	}

	// Unmarshal result as a boolean.
	var moveResult bool
	err = json.Unmarshal(res, &moveResult)
	if err != nil {
		return false, err
	}

	return moveResult, nil
}

// MoveAsync returns an instance of a type that can be used to get the result of
// the RPC at some future time by invoking the Receive function on the returned
// instance.
//
// See Move for the blocking version and more details.
func (c *Client) MoveAsync(ctx context.Context, fromAccount, toAccount string, amount btcutil.Amount) FutureMoveResult {
	cmd := btcjson.NewMoveCmd(fromAccount, toAccount, amount.ToBTC(), nil,
		nil)
	return c.SendCmd(ctx, cmd)
}

// Move moves specified amount from one account in your wallet to another.  Only
// funds with the default number of minimum confirmations will be used.
//
// See MoveMinConf and MoveComment for different options.
func (c *Client) Move(ctx context.Context, fromAccount, toAccount string, amount btcutil.Amount) (bool, error) {
	return c.MoveAsync(ctx, fromAccount, toAccount, amount).Receive()
}

// MoveMinConfAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See MoveMinConf for the blocking version and more details.
func (c *Client) MoveMinConfAsync(ctx context.Context, fromAccount, toAccount string,
	amount btcutil.Amount, minConfirms int,
) FutureMoveResult {
	cmd := btcjson.NewMoveCmd(fromAccount, toAccount, amount.ToBTC(),
		&minConfirms, nil)
	return c.SendCmd(ctx, cmd)
}

// MoveMinConf moves specified amount from one account in your wallet to
// another.  Only funds with the passed number of minimum confirmations will be
// used.
//
// See Move to use the default number of minimum confirmations and MoveComment
// for additional options.
func (c *Client) MoveMinConf(ctx context.Context, fromAccount, toAccount string, amount btcutil.Amount, minConf int) (bool, error) {
	return c.MoveMinConfAsync(ctx, fromAccount, toAccount, amount, minConf).Receive()
}

// MoveCommentAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See MoveComment for the blocking version and more details.
func (c *Client) MoveCommentAsync(ctx context.Context, fromAccount, toAccount string,
	amount btcutil.Amount, minConfirms int, comment string,
) FutureMoveResult {
	cmd := btcjson.NewMoveCmd(fromAccount, toAccount, amount.ToBTC(),
		&minConfirms, &comment)
	return c.SendCmd(ctx, cmd)
}

// MoveComment moves specified amount from one account in your wallet to
// another and stores the provided comment in the wallet.  The comment
// parameter is only available in the wallet.  Only funds with the passed number
// of minimum confirmations will be used.
//
// See Move and MoveMinConf to use defaults.
func (c *Client) MoveComment(ctx context.Context, fromAccount, toAccount string, amount btcutil.Amount,
	minConf int, comment string,
) (bool, error) {
	return c.MoveCommentAsync(ctx, fromAccount, toAccount, amount, minConf,
		comment).Receive()
}

// FutureRenameAccountResult is a future promise to deliver the result of a
// RenameAccountAsync RPC invocation (or an applicable error).
type FutureRenameAccountResult chan *Response

// Receive waits for the Response promised by the future and returns the
// result of creating new account.
func (r FutureRenameAccountResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// RenameAccountAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See RenameAccount for the blocking version and more details.
func (c *Client) RenameAccountAsync(ctx context.Context, oldAccount, newAccount string) FutureRenameAccountResult {
	cmd := btcjson.NewRenameAccountCmd(oldAccount, newAccount)
	return c.SendCmd(ctx, cmd)
}

// RenameAccount creates a new wallet account.
func (c *Client) RenameAccount(ctx context.Context, oldAccount, newAccount string) error {
	return c.RenameAccountAsync(ctx, oldAccount, newAccount).Receive()
}

// FutureValidateAddressResult is a future promise to deliver the result of a
// ValidateAddressAsync RPC invocation (or an applicable error).
type FutureValidateAddressResult chan *Response

// Receive waits for the Response promised by the future and returns information
// about the given bitcoin address.
func (r FutureValidateAddressResult) Receive() (*btcjson.ValidateAddressWalletResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a validateaddress result object.
	var addrResult btcjson.ValidateAddressWalletResult
	err = json.Unmarshal(res, &addrResult)
	if err != nil {
		return nil, err
	}

	return &addrResult, nil
}

// ValidateAddressAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See ValidateAddress for the blocking version and more details.
func (c *Client) ValidateAddressAsync(ctx context.Context, address btcutil.Address) FutureValidateAddressResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewValidateAddressCmd(addr)
	return c.SendCmd(ctx, cmd)
}

// ValidateAddress returns information about the given bitcoin address.
func (c *Client) ValidateAddress(ctx context.Context, address btcutil.Address) (*btcjson.ValidateAddressWalletResult, error) {
	return c.ValidateAddressAsync(ctx, address).Receive()
}

// FutureKeyPoolRefillResult is a future promise to deliver the result of a
// KeyPoolRefillAsync RPC invocation (or an applicable error).
type FutureKeyPoolRefillResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of refilling the key pool.
func (r FutureKeyPoolRefillResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// KeyPoolRefillAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See KeyPoolRefill for the blocking version and more details.
func (c *Client) KeyPoolRefillAsync(ctx context.Context) FutureKeyPoolRefillResult {
	cmd := btcjson.NewKeyPoolRefillCmd(nil)
	return c.SendCmd(ctx, cmd)
}

// KeyPoolRefill fills the key pool as necessary to reach the default size.
//
// See KeyPoolRefillSize to override the size of the key pool.
func (c *Client) KeyPoolRefill(ctx context.Context) error {
	return c.KeyPoolRefillAsync(ctx).Receive()
}

// KeyPoolRefillSizeAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See KeyPoolRefillSize for the blocking version and more details.
func (c *Client) KeyPoolRefillSizeAsync(ctx context.Context, newSize uint) FutureKeyPoolRefillResult {
	cmd := btcjson.NewKeyPoolRefillCmd(&newSize)
	return c.SendCmd(ctx, cmd)
}

// KeyPoolRefillSize fills the key pool as necessary to reach the specified
// size.
func (c *Client) KeyPoolRefillSize(ctx context.Context, newSize uint) error {
	return c.KeyPoolRefillSizeAsync(ctx, newSize).Receive()
}

// ************************
// Amount/Balance Functions
// ************************

// FutureListAccountsResult is a future promise to deliver the result of a
// ListAccountsAsync or ListAccountsMinConfAsync RPC invocation (or an
// applicable error).
type FutureListAccountsResult chan *Response

// Receive waits for the Response promised by the future and returns returns a
// map of account names and their associated balances.
func (r FutureListAccountsResult) Receive() (map[string]btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a json object.
	var accounts map[string]float64
	err = json.Unmarshal(res, &accounts)
	if err != nil {
		return nil, err
	}

	accountsMap := make(map[string]btcutil.Amount)
	for k, v := range accounts {
		amount, err := btcutil.NewAmount(v)
		if err != nil {
			return nil, err
		}

		accountsMap[k] = amount
	}

	return accountsMap, nil
}

// ListAccountsAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ListAccounts for the blocking version and more details.
func (c *Client) ListAccountsAsync(ctx context.Context) FutureListAccountsResult {
	cmd := btcjson.NewListAccountsCmd(nil)
	return c.SendCmd(ctx, cmd)
}

// ListAccounts returns a map of account names and their associated balances
// using the default number of minimum confirmations.
//
// See ListAccountsMinConf to override the minimum number of confirmations.
func (c *Client) ListAccounts(ctx context.Context) (map[string]btcutil.Amount, error) {
	return c.ListAccountsAsync(ctx).Receive()
}

// ListAccountsMinConfAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListAccountsMinConf for the blocking version and more details.
func (c *Client) ListAccountsMinConfAsync(ctx context.Context, minConfirms int) FutureListAccountsResult {
	cmd := btcjson.NewListAccountsCmd(&minConfirms)
	return c.SendCmd(ctx, cmd)
}

// ListAccountsMinConf returns a map of account names and their associated
// balances using the specified number of minimum confirmations.
//
// See ListAccounts to use the default minimum number of confirmations.
func (c *Client) ListAccountsMinConf(ctx context.Context, minConfirms int) (map[string]btcutil.Amount, error) {
	return c.ListAccountsMinConfAsync(ctx, minConfirms).Receive()
}

// FutureGetBalanceResult is a future promise to deliver the result of a
// GetBalanceAsync or GetBalanceMinConfAsync RPC invocation (or an applicable
// error).
type FutureGetBalanceResult chan *Response

// Receive waits for the Response promised by the future and returns the
// available balance from the server for the specified account.
func (r FutureGetBalanceResult) Receive() (btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return 0, err
	}

	// Unmarshal result as a floating point number.
	var balance float64
	err = json.Unmarshal(res, &balance)
	if err != nil {
		return 0, err
	}

	amount, err := btcutil.NewAmount(balance)
	if err != nil {
		return 0, err
	}

	return amount, nil
}

// FutureGetBalanceParseResult is same as FutureGetBalanceResult except
// that the result is expected to be a string which is then parsed into
// a float64 value
// This is required for compatibility with servers like blockchain.info
type FutureGetBalanceParseResult chan *Response

// Receive waits for the Response promised by the future and returns the
// available balance from the server for the specified account.
func (r FutureGetBalanceParseResult) Receive() (btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return 0, err
	}

	// Unmarshal result as a string
	var balanceString string
	err = json.Unmarshal(res, &balanceString)
	if err != nil {
		return 0, err
	}

	balance, err := strconv.ParseFloat(balanceString, 64)
	if err != nil {
		return 0, err
	}
	amount, err := btcutil.NewAmount(balance)
	if err != nil {
		return 0, err
	}

	return amount, nil
}

// GetBalanceAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetBalance for the blocking version and more details.
func (c *Client) GetBalanceAsync(ctx context.Context, account string) FutureGetBalanceResult {
	cmd := btcjson.NewGetBalanceCmd(&account, nil)
	return c.SendCmd(ctx, cmd)
}

// GetBalance returns the available balance from the server for the specified
// account using the default number of minimum confirmations.  The account may
// be "*" for all accounts.
//
// See GetBalanceMinConf to override the minimum number of confirmations.
func (c *Client) GetBalance(ctx context.Context, account string) (btcutil.Amount, error) {
	return c.GetBalanceAsync(ctx, account).Receive()
}

// GetBalanceMinConfAsync returns an instance of a type that can be used to get
// the result of the RPC at some future time by invoking the Receive function on
// the returned instance.
//
// See GetBalanceMinConf for the blocking version and more details.
func (c *Client) GetBalanceMinConfAsync(ctx context.Context, account string, minConfirms int) FutureGetBalanceResult {
	cmd := btcjson.NewGetBalanceCmd(&account, &minConfirms)
	return c.SendCmd(ctx, cmd)
}

// GetBalanceMinConf returns the available balance from the server for the
// specified account using the specified number of minimum confirmations.  The
// account may be "*" for all accounts.
//
// See GetBalance to use the default minimum number of confirmations.
func (c *Client) GetBalanceMinConf(ctx context.Context, account string, minConfirms int) (btcutil.Amount, error) {
	if c.config.EnableBCInfoHacks {
		response := c.GetBalanceMinConfAsync(ctx, account, minConfirms)
		return FutureGetBalanceParseResult(response).Receive()
	}
	return c.GetBalanceMinConfAsync(ctx, account, minConfirms).Receive()
}

// FutureGetBalancesResult is a future promise to deliver the result of a
// GetBalancesAsync RPC invocation (or an applicable error).
type FutureGetBalancesResult chan *Response

// Receive waits for the Response promised by the future and returns the
// available balances from the server.
func (r FutureGetBalancesResult) Receive() (*btcjson.GetBalancesResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a floating point number.
	var balances btcjson.GetBalancesResult
	err = json.Unmarshal(res, &balances)
	if err != nil {
		return nil, err
	}

	return &balances, nil
}

// GetBalancesAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetBalances for the blocking version and more details.
func (c *Client) GetBalancesAsync(ctx context.Context) FutureGetBalancesResult {
	cmd := btcjson.NewGetBalancesCmd()
	return c.SendCmd(ctx, cmd)
}

// GetBalances returns the available balances from the server.
func (c *Client) GetBalances(ctx context.Context) (*btcjson.GetBalancesResult, error) {
	return c.GetBalancesAsync(ctx).Receive()
}

// FutureGetReceivedByAccountResult is a future promise to deliver the result of
// a GetReceivedByAccountAsync or GetReceivedByAccountMinConfAsync RPC
// invocation (or an applicable error).
type FutureGetReceivedByAccountResult chan *Response

// Receive waits for the Response promised by the future and returns the total
// amount received with the specified account.
func (r FutureGetReceivedByAccountResult) Receive() (btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return 0, err
	}

	// Unmarshal result as a floating point number.
	var balance float64
	err = json.Unmarshal(res, &balance)
	if err != nil {
		return 0, err
	}

	amount, err := btcutil.NewAmount(balance)
	if err != nil {
		return 0, err
	}

	return amount, nil
}

// GetReceivedByAccountAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetReceivedByAccount for the blocking version and more details.
func (c *Client) GetReceivedByAccountAsync(ctx context.Context, account string) FutureGetReceivedByAccountResult {
	cmd := btcjson.NewGetReceivedByAccountCmd(account, nil)
	return c.SendCmd(ctx, cmd)
}

// GetReceivedByAccount returns the total amount received with the specified
// account with at least the default number of minimum confirmations.
//
// See GetReceivedByAccountMinConf to override the minimum number of
// confirmations.
func (c *Client) GetReceivedByAccount(ctx context.Context, account string) (btcutil.Amount, error) {
	return c.GetReceivedByAccountAsync(ctx, account).Receive()
}

// GetReceivedByAccountMinConfAsync returns an instance of a type that can be
// used to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetReceivedByAccountMinConf for the blocking version and more details.
func (c *Client) GetReceivedByAccountMinConfAsync(ctx context.Context, account string, minConfirms int) FutureGetReceivedByAccountResult {
	cmd := btcjson.NewGetReceivedByAccountCmd(account, &minConfirms)
	return c.SendCmd(ctx, cmd)
}

// GetReceivedByAccountMinConf returns the total amount received with the
// specified account with at least the specified number of minimum
// confirmations.
//
// See GetReceivedByAccount to use the default minimum number of confirmations.
func (c *Client) GetReceivedByAccountMinConf(ctx context.Context, account string, minConfirms int) (btcutil.Amount, error) {
	return c.GetReceivedByAccountMinConfAsync(ctx, account, minConfirms).Receive()
}

// FutureGetUnconfirmedBalanceResult is a future promise to deliver the result
// of a GetUnconfirmedBalanceAsync RPC invocation (or an applicable error).
type FutureGetUnconfirmedBalanceResult chan *Response

// Receive waits for the Response promised by the future and returns returns the
// unconfirmed balance from the server for the specified account.
func (r FutureGetUnconfirmedBalanceResult) Receive() (btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return 0, err
	}

	// Unmarshal result as a floating point number.
	var balance float64
	err = json.Unmarshal(res, &balance)
	if err != nil {
		return 0, err
	}

	amount, err := btcutil.NewAmount(balance)
	if err != nil {
		return 0, err
	}

	return amount, nil
}

// GetUnconfirmedBalanceAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetUnconfirmedBalance for the blocking version and more details.
func (c *Client) GetUnconfirmedBalanceAsync(ctx context.Context, account string) FutureGetUnconfirmedBalanceResult {
	cmd := btcjson.NewGetUnconfirmedBalanceCmd(&account)
	return c.SendCmd(ctx, cmd)
}

// GetUnconfirmedBalance returns the unconfirmed balance from the server for
// the specified account.
func (c *Client) GetUnconfirmedBalance(ctx context.Context, account string) (btcutil.Amount, error) {
	return c.GetUnconfirmedBalanceAsync(ctx, account).Receive()
}

// FutureGetReceivedByAddressResult is a future promise to deliver the result of
// a GetReceivedByAddressAsync or GetReceivedByAddressMinConfAsync RPC
// invocation (or an applicable error).
type FutureGetReceivedByAddressResult chan *Response

// Receive waits for the Response promised by the future and returns the total
// amount received by the specified address.
func (r FutureGetReceivedByAddressResult) Receive() (btcutil.Amount, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return 0, err
	}

	// Unmarshal result as a floating point number.
	var balance float64
	err = json.Unmarshal(res, &balance)
	if err != nil {
		return 0, err
	}

	amount, err := btcutil.NewAmount(balance)
	if err != nil {
		return 0, err
	}

	return amount, nil
}

// GetReceivedByAddressAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetReceivedByAddress for the blocking version and more details.
func (c *Client) GetReceivedByAddressAsync(ctx context.Context, address btcutil.Address) FutureGetReceivedByAddressResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewGetReceivedByAddressCmd(addr, nil)
	return c.SendCmd(ctx, cmd)
}

// GetReceivedByAddress returns the total amount received by the specified
// address with at least the default number of minimum confirmations.
//
// See GetReceivedByAddressMinConf to override the minimum number of
// confirmations.
func (c *Client) GetReceivedByAddress(ctx context.Context, address btcutil.Address) (btcutil.Amount, error) {
	return c.GetReceivedByAddressAsync(ctx, address).Receive()
}

// GetReceivedByAddressMinConfAsync returns an instance of a type that can be
// used to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See GetReceivedByAddressMinConf for the blocking version and more details.
func (c *Client) GetReceivedByAddressMinConfAsync(ctx context.Context, address btcutil.Address, minConfirms int) FutureGetReceivedByAddressResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewGetReceivedByAddressCmd(addr, &minConfirms)
	return c.SendCmd(ctx, cmd)
}

// GetReceivedByAddressMinConf returns the total amount received by the specified
// address with at least the specified number of minimum confirmations.
//
// See GetReceivedByAddress to use the default minimum number of confirmations.
func (c *Client) GetReceivedByAddressMinConf(ctx context.Context, address btcutil.Address, minConfirms int) (btcutil.Amount, error) {
	return c.GetReceivedByAddressMinConfAsync(ctx, address, minConfirms).Receive()
}

// FutureListReceivedByAccountResult is a future promise to deliver the result
// of a ListReceivedByAccountAsync, ListReceivedByAccountMinConfAsync, or
// ListReceivedByAccountIncludeEmptyAsync RPC invocation (or an applicable
// error).
type FutureListReceivedByAccountResult chan *Response

// Receive waits for the Response promised by the future and returns a list of
// balances by account.
func (r FutureListReceivedByAccountResult) Receive() ([]btcjson.ListReceivedByAccountResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal as an array of listreceivedbyaccount result objects.
	var received []btcjson.ListReceivedByAccountResult
	err = json.Unmarshal(res, &received)
	if err != nil {
		return nil, err
	}

	return received, nil
}

// ListReceivedByAccountAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListReceivedByAccount for the blocking version and more details.
func (c *Client) ListReceivedByAccountAsync(ctx context.Context) FutureListReceivedByAccountResult {
	cmd := btcjson.NewListReceivedByAccountCmd(nil, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAccount lists balances by account using the default number
// of minimum confirmations and including accounts that haven't received any
// payments.
//
// See ListReceivedByAccountMinConf to override the minimum number of
// confirmations and ListReceivedByAccountIncludeEmpty to filter accounts that
// haven't received any payments from the results.
func (c *Client) ListReceivedByAccount(ctx context.Context) ([]btcjson.ListReceivedByAccountResult, error) {
	return c.ListReceivedByAccountAsync(ctx).Receive()
}

// ListReceivedByAccountMinConfAsync returns an instance of a type that can be
// used to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListReceivedByAccountMinConf for the blocking version and more details.
func (c *Client) ListReceivedByAccountMinConfAsync(ctx context.Context, minConfirms int) FutureListReceivedByAccountResult {
	cmd := btcjson.NewListReceivedByAccountCmd(&minConfirms, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAccountMinConf lists balances by account using the specified
// number of minimum confirmations not including accounts that haven't received
// any payments.
//
// See ListReceivedByAccount to use the default minimum number of confirmations
// and ListReceivedByAccountIncludeEmpty to also include accounts that haven't
// received any payments in the results.
func (c *Client) ListReceivedByAccountMinConf(ctx context.Context, minConfirms int) ([]btcjson.ListReceivedByAccountResult, error) {
	return c.ListReceivedByAccountMinConfAsync(ctx, minConfirms).Receive()
}

// ListReceivedByAccountIncludeEmptyAsync returns an instance of a type that can
// be used to get the result of the RPC at some future time by invoking the
// Receive function on the returned instance.
//
// See ListReceivedByAccountIncludeEmpty for the blocking version and more details.
func (c *Client) ListReceivedByAccountIncludeEmptyAsync(ctx context.Context, minConfirms int, includeEmpty bool) FutureListReceivedByAccountResult {
	cmd := btcjson.NewListReceivedByAccountCmd(&minConfirms, &includeEmpty,
		nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAccountIncludeEmpty lists balances by account using the
// specified number of minimum confirmations and including accounts that
// haven't received any payments depending on specified flag.
//
// See ListReceivedByAccount and ListReceivedByAccountMinConf to use defaults.
func (c *Client) ListReceivedByAccountIncludeEmpty(ctx context.Context, minConfirms int, includeEmpty bool) ([]btcjson.ListReceivedByAccountResult, error) {
	return c.ListReceivedByAccountIncludeEmptyAsync(ctx, minConfirms,
		includeEmpty).Receive()
}

// FutureListReceivedByAddressResult is a future promise to deliver the result
// of a ListReceivedByAddressAsync, ListReceivedByAddressMinConfAsync, or
// ListReceivedByAddressIncludeEmptyAsync RPC invocation (or an applicable
// error).
type FutureListReceivedByAddressResult chan *Response

// Receive waits for the Response promised by the future and returns a list of
// balances by address.
func (r FutureListReceivedByAddressResult) Receive() ([]btcjson.ListReceivedByAddressResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal as an array of listreceivedbyaddress result objects.
	var received []btcjson.ListReceivedByAddressResult
	err = json.Unmarshal(res, &received)
	if err != nil {
		return nil, err
	}

	return received, nil
}

// ListReceivedByAddressAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListReceivedByAddress for the blocking version and more details.
func (c *Client) ListReceivedByAddressAsync(ctx context.Context) FutureListReceivedByAddressResult {
	cmd := btcjson.NewListReceivedByAddressCmd(nil, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAddress lists balances by address using the default number
// of minimum confirmations not including addresses that haven't received any
// payments or watching only addresses.
//
// See ListReceivedByAddressMinConf to override the minimum number of
// confirmations and ListReceivedByAddressIncludeEmpty to also include addresses
// that haven't received any payments in the results.
func (c *Client) ListReceivedByAddress(ctx context.Context) ([]btcjson.ListReceivedByAddressResult, error) {
	return c.ListReceivedByAddressAsync(ctx).Receive()
}

// ListReceivedByAddressMinConfAsync returns an instance of a type that can be
// used to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See ListReceivedByAddressMinConf for the blocking version and more details.
func (c *Client) ListReceivedByAddressMinConfAsync(ctx context.Context, minConfirms int) FutureListReceivedByAddressResult {
	cmd := btcjson.NewListReceivedByAddressCmd(&minConfirms, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAddressMinConf lists balances by address using the specified
// number of minimum confirmations not including addresses that haven't received
// any payments.
//
// See ListReceivedByAddress to use the default minimum number of confirmations
// and ListReceivedByAddressIncludeEmpty to also include addresses that haven't
// received any payments in the results.
func (c *Client) ListReceivedByAddressMinConf(ctx context.Context, minConfirms int) ([]btcjson.ListReceivedByAddressResult, error) {
	return c.ListReceivedByAddressMinConfAsync(ctx, minConfirms).Receive()
}

// ListReceivedByAddressIncludeEmptyAsync returns an instance of a type that can
// be used to get the result of the RPC at some future time by invoking the
// Receive function on the returned instance.
//
// See ListReceivedByAccountIncludeEmpty for the blocking version and more details.
func (c *Client) ListReceivedByAddressIncludeEmptyAsync(ctx context.Context, minConfirms int, includeEmpty bool) FutureListReceivedByAddressResult {
	cmd := btcjson.NewListReceivedByAddressCmd(&minConfirms, &includeEmpty,
		nil)
	return c.SendCmd(ctx, cmd)
}

// ListReceivedByAddressIncludeEmpty lists balances by address using the
// specified number of minimum confirmations and including addresses that
// haven't received any payments depending on specified flag.
//
// See ListReceivedByAddress and ListReceivedByAddressMinConf to use defaults.
func (c *Client) ListReceivedByAddressIncludeEmpty(ctx context.Context, minConfirms int, includeEmpty bool) ([]btcjson.ListReceivedByAddressResult, error) {
	return c.ListReceivedByAddressIncludeEmptyAsync(ctx, minConfirms,
		includeEmpty).Receive()
}

// ************************
// Wallet Locking Functions
// ************************

// FutureWalletLockResult is a future promise to deliver the result of a
// WalletLockAsync RPC invocation (or an applicable error).
type FutureWalletLockResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of locking the wallet.
func (r FutureWalletLockResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// WalletLockAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See WalletLock for the blocking version and more details.
func (c *Client) WalletLockAsync(ctx context.Context) FutureWalletLockResult {
	cmd := btcjson.NewWalletLockCmd()
	return c.SendCmd(ctx, cmd)
}

// WalletLock locks the wallet by removing the encryption key from memory.
//
// After calling this function, the WalletPassphrase function must be used to
// unlock the wallet prior to calling any other function which requires the
// wallet to be unlocked.
func (c *Client) WalletLock(ctx context.Context) error {
	return c.WalletLockAsync(ctx).Receive()
}

// WalletPassphrase unlocks the wallet by using the passphrase to derive the
// decryption key which is then stored in memory for the specified timeout
// (in seconds).
func (c *Client) WalletPassphrase(ctx context.Context, passphrase string, timeoutSecs int64) error {
	cmd := btcjson.NewWalletPassphraseCmd(passphrase, timeoutSecs)
	_, err := c.sendCmdAndWait(ctx, cmd)
	return err
}

// FutureWalletPassphraseChangeResult is a future promise to deliver the result
// of a WalletPassphraseChangeAsync RPC invocation (or an applicable error).
type FutureWalletPassphraseChangeResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of changing the wallet passphrase.
func (r FutureWalletPassphraseChangeResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// WalletPassphraseChangeAsync returns an instance of a type that can be used to
// get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See WalletPassphraseChange for the blocking version and more details.
func (c *Client) WalletPassphraseChangeAsync(ctx context.Context, old, new string) FutureWalletPassphraseChangeResult {
	cmd := btcjson.NewWalletPassphraseChangeCmd(old, new)
	return c.SendCmd(ctx, cmd)
}

// WalletPassphraseChange changes the wallet passphrase from the specified old
// to new passphrase.
func (c *Client) WalletPassphraseChange(ctx context.Context, old, new string) error {
	return c.WalletPassphraseChangeAsync(ctx, old, new).Receive()
}

// *************************
// Message Signing Functions
// *************************

// FutureSignMessageResult is a future promise to deliver the result of a
// SignMessageAsync RPC invocation (or an applicable error).
type FutureSignMessageResult chan *Response

// Receive waits for the Response promised by the future and returns the message
// signed with the private key of the specified address.
func (r FutureSignMessageResult) Receive() (string, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return "", err
	}

	// Unmarshal result as a string.
	var b64 string
	err = json.Unmarshal(res, &b64)
	if err != nil {
		return "", err
	}

	return b64, nil
}

// SignMessageAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See SignMessage for the blocking version and more details.
func (c *Client) SignMessageAsync(ctx context.Context, address btcutil.Address, message string) FutureSignMessageResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewSignMessageCmd(addr, message)
	return c.SendCmd(ctx, cmd)
}

// SignMessage signs a message with the private key of the specified address.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) SignMessage(ctx context.Context, address btcutil.Address, message string) (string, error) {
	return c.SignMessageAsync(ctx, address, message).Receive()
}

// FutureVerifyMessageResult is a future promise to deliver the result of a
// VerifyMessageAsync RPC invocation (or an applicable error).
type FutureVerifyMessageResult chan *Response

// Receive waits for the Response promised by the future and returns whether or
// not the message was successfully verified.
func (r FutureVerifyMessageResult) Receive() (bool, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return false, err
	}

	// Unmarshal result as a boolean.
	var verified bool
	err = json.Unmarshal(res, &verified)
	if err != nil {
		return false, err
	}

	return verified, nil
}

// VerifyMessageAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See VerifyMessage for the blocking version and more details.
func (c *Client) VerifyMessageAsync(ctx context.Context, address btcutil.Address, signature, message string) FutureVerifyMessageResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewVerifyMessageCmd(addr, signature, message)
	return c.SendCmd(ctx, cmd)
}

// VerifyMessage verifies a signed message.
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) VerifyMessage(ctx context.Context, address btcutil.Address, signature, message string) (bool, error) {
	return c.VerifyMessageAsync(ctx, address, signature, message).Receive()
}

// *********************
// Dump/Import Functions
// *********************

// FutureDumpPrivKeyResult is a future promise to deliver the result of a
// DumpPrivKeyAsync RPC invocation (or an applicable error).
type FutureDumpPrivKeyResult chan *Response

// Receive waits for the Response promised by the future and returns the private
// key corresponding to the passed address encoded in the wallet import format
// (WIF)
func (r FutureDumpPrivKeyResult) Receive() (*btcutil.WIF, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a string.
	var privKeyWIF string
	err = json.Unmarshal(res, &privKeyWIF)
	if err != nil {
		return nil, err
	}

	return btcutil.DecodeWIF(privKeyWIF)
}

// DumpPrivKeyAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See DumpPrivKey for the blocking version and more details.
func (c *Client) DumpPrivKeyAsync(ctx context.Context, address btcutil.Address) FutureDumpPrivKeyResult {
	addr := address.EncodeAddress()
	cmd := btcjson.NewDumpPrivKeyCmd(addr)
	return c.SendCmd(ctx, cmd)
}

// DumpPrivKey gets the private key corresponding to the passed address encoded
// in the wallet import format (WIF).
//
// NOTE: This function requires to the wallet to be unlocked.  See the
// WalletPassphrase function for more details.
func (c *Client) DumpPrivKey(ctx context.Context, address btcutil.Address) (*btcutil.WIF, error) {
	return c.DumpPrivKeyAsync(ctx, address).Receive()
}

// FutureImportAddressResult is a future promise to deliver the result of an
// ImportAddressAsync RPC invocation (or an applicable error).
type FutureImportAddressResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of importing the passed public address.
func (r FutureImportAddressResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// ImportAddressAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportAddress for the blocking version and more details.
func (c *Client) ImportAddressAsync(ctx context.Context, address string) FutureImportAddressResult {
	cmd := btcjson.NewImportAddressCmd(address, "", nil)
	return c.SendCmd(ctx, cmd)
}

// ImportAddress imports the passed public address.
func (c *Client) ImportAddress(ctx context.Context, address string) error {
	return c.ImportAddressAsync(ctx, address).Receive()
}

// ImportAddressRescanAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportAddress for the blocking version and more details.
func (c *Client) ImportAddressRescanAsync(ctx context.Context, address string, account string, rescan bool) FutureImportAddressResult {
	cmd := btcjson.NewImportAddressCmd(address, account, &rescan)
	return c.SendCmd(ctx, cmd)
}

// ImportAddressRescan imports the passed public address. When rescan is true,
// the block history is scanned for transactions addressed to provided address.
func (c *Client) ImportAddressRescan(ctx context.Context, address string, account string, rescan bool) error {
	return c.ImportAddressRescanAsync(ctx, address, account, rescan).Receive()
}

// FutureImportMultiResult is a future promise to deliver the result of an
// ImportMultiAsync RPC invocation (or an applicable error).
type FutureImportMultiResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of importing multiple addresses/scripts.
func (r FutureImportMultiResult) Receive() (btcjson.ImportMultiResults, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var importMultiResults btcjson.ImportMultiResults
	err = json.Unmarshal(res, &importMultiResults)
	if err != nil {
		return nil, err
	}
	return importMultiResults, nil
}

// ImportMultiAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportMulti for the blocking version and more details.
func (c *Client) ImportMultiAsync(ctx context.Context, requests []btcjson.ImportMultiRequest, options *btcjson.ImportMultiOptions) FutureImportMultiResult {
	cmd := btcjson.NewImportMultiCmd(requests, options)
	return c.SendCmd(ctx, cmd)
}

// ImportMulti imports addresses/scripts, optionally rescanning the blockchain
// from the earliest creation time of the imported scripts.
//
// See btcjson.ImportMultiRequest for details on the requests parameter.
func (c *Client) ImportMulti(ctx context.Context, requests []btcjson.ImportMultiRequest, options *btcjson.ImportMultiOptions) (btcjson.ImportMultiResults, error) {
	return c.ImportMultiAsync(ctx, requests, options).Receive()
}

// FutureImportPrivKeyResult is a future promise to deliver the result of an
// ImportPrivKeyAsync RPC invocation (or an applicable error).
type FutureImportPrivKeyResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of importing the passed private key which must be the wallet import format
// (WIF).
func (r FutureImportPrivKeyResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// ImportPrivKeyAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportPrivKey for the blocking version and more details.
func (c *Client) ImportPrivKeyAsync(ctx context.Context, privKeyWIF *btcutil.WIF) FutureImportPrivKeyResult {
	wif := ""
	if privKeyWIF != nil {
		wif = privKeyWIF.String()
	}

	cmd := btcjson.NewImportPrivKeyCmd(wif, nil, nil)
	return c.SendCmd(ctx, cmd)
}

// ImportPrivKey imports the passed private key which must be the wallet import
// format (WIF).
func (c *Client) ImportPrivKey(ctx context.Context, privKeyWIF *btcutil.WIF) error {
	return c.ImportPrivKeyAsync(ctx, privKeyWIF).Receive()
}

// ImportPrivKeyLabelAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportPrivKey for the blocking version and more details.
func (c *Client) ImportPrivKeyLabelAsync(ctx context.Context, privKeyWIF *btcutil.WIF, label string) FutureImportPrivKeyResult {
	wif := ""
	if privKeyWIF != nil {
		wif = privKeyWIF.String()
	}

	cmd := btcjson.NewImportPrivKeyCmd(wif, &label, nil)
	return c.SendCmd(ctx, cmd)
}

// ImportPrivKeyLabel imports the passed private key which must be the wallet import
// format (WIF). It sets the account label to the one provided.
func (c *Client) ImportPrivKeyLabel(ctx context.Context, privKeyWIF *btcutil.WIF, label string) error {
	return c.ImportPrivKeyLabelAsync(ctx, privKeyWIF, label).Receive()
}

// ImportPrivKeyRescanAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportPrivKey for the blocking version and more details.
func (c *Client) ImportPrivKeyRescanAsync(ctx context.Context, privKeyWIF *btcutil.WIF, label string, rescan bool) FutureImportPrivKeyResult {
	wif := ""
	if privKeyWIF != nil {
		wif = privKeyWIF.String()
	}

	cmd := btcjson.NewImportPrivKeyCmd(wif, &label, &rescan)
	return c.SendCmd(ctx, cmd)
}

// ImportPrivKeyRescan imports the passed private key which must be the wallet import
// format (WIF). It sets the account label to the one provided. When rescan is true,
// the block history is scanned for transactions addressed to provided privKey.
func (c *Client) ImportPrivKeyRescan(ctx context.Context, privKeyWIF *btcutil.WIF, label string, rescan bool) error {
	return c.ImportPrivKeyRescanAsync(ctx, privKeyWIF, label, rescan).Receive()
}

// FutureImportPubKeyResult is a future promise to deliver the result of an
// ImportPubKeyAsync RPC invocation (or an applicable error).
type FutureImportPubKeyResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of importing the passed public key.
func (r FutureImportPubKeyResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// ImportPubKeyAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportPubKey for the blocking version and more details.
func (c *Client) ImportPubKeyAsync(ctx context.Context, pubKey string) FutureImportPubKeyResult {
	cmd := btcjson.NewImportPubKeyCmd(pubKey, nil)
	return c.SendCmd(ctx, cmd)
}

// ImportPubKey imports the passed public key.
func (c *Client) ImportPubKey(ctx context.Context, pubKey string) error {
	return c.ImportPubKeyAsync(ctx, pubKey).Receive()
}

// ImportPubKeyRescanAsync returns an instance of a type that can be used to get the
// result of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportPubKey for the blocking version and more details.
func (c *Client) ImportPubKeyRescanAsync(ctx context.Context, pubKey string, rescan bool) FutureImportPubKeyResult {
	cmd := btcjson.NewImportPubKeyCmd(pubKey, &rescan)
	return c.SendCmd(ctx, cmd)
}

// ImportPubKeyRescan imports the passed public key. When rescan is true, the
// block history is scanned for transactions addressed to provided pubkey.
func (c *Client) ImportPubKeyRescan(ctx context.Context, pubKey string, rescan bool) error {
	return c.ImportPubKeyRescanAsync(ctx, pubKey, rescan).Receive()
}

// ***********************
// Miscellaneous Functions
// ***********************

// NOTE: While getinfo is implemented here (in wallet.go), a btcd chain server
// will respond to getinfo requests as well, excluding any wallet information.

// FutureGetInfoResult is a future promise to deliver the result of a
// GetInfoAsync RPC invocation (or an applicable error).
type FutureGetInfoResult chan *Response

// Receive waits for the Response promised by the future and returns the info
// provided by the server.
func (r FutureGetInfoResult) Receive() (*btcjson.InfoWalletResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a getinfo result object.
	var infoRes btcjson.InfoWalletResult
	err = json.Unmarshal(res, &infoRes)
	if err != nil {
		return nil, err
	}

	return &infoRes, nil
}

// GetInfoAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetInfo for the blocking version and more details.
func (c *Client) GetInfoAsync(ctx context.Context) FutureGetInfoResult {
	cmd := btcjson.NewGetInfoCmd()
	return c.SendCmd(ctx, cmd)
}

// GetInfo returns miscellaneous info regarding the RPC server.  The returned
// info object may be void of wallet information if the remote server does
// not include wallet functionality.
func (c *Client) GetInfo(ctx context.Context) (*btcjson.InfoWalletResult, error) {
	return c.GetInfoAsync(ctx).Receive()
}

// FutureWalletCreateFundedPsbtResult is a future promise to deliver the result of an
// WalletCreateFundedPsbt RPC invocation (or an applicable error).
type FutureWalletCreateFundedPsbtResult chan *Response

// Receive waits for the Response promised by the future and returns the
// partially signed transaction in PSBT format along with the resulting fee
// and change output index.
func (r FutureWalletCreateFundedPsbtResult) Receive() (*btcjson.WalletCreateFundedPsbtResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a getinfo result object.
	var psbtRes btcjson.WalletCreateFundedPsbtResult
	err = json.Unmarshal(res, &psbtRes)
	if err != nil {
		return nil, err
	}

	return &psbtRes, nil
}

// WalletCreateFundedPsbtAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See WalletCreateFundedPsbt for the blocking version and more details.
func (c *Client) WalletCreateFundedPsbtAsync(
	ctx context.Context, inputs []btcjson.PsbtInput, outputs []btcjson.PsbtOutput, locktime *uint32,
	options *btcjson.WalletCreateFundedPsbtOpts, bip32Derivs *bool,
) FutureWalletCreateFundedPsbtResult {
	cmd := btcjson.NewWalletCreateFundedPsbtCmd(inputs, outputs, locktime, options, bip32Derivs)
	return c.SendCmd(ctx, cmd)
}

// WalletCreateFundedPsbt creates and funds a transaction in the Partially
// Signed Transaction format. Inputs will be added if supplied inputs are not
// enough.
func (c *Client) WalletCreateFundedPsbt(
	ctx context.Context, inputs []btcjson.PsbtInput, outputs []btcjson.PsbtOutput, locktime *uint32,
	options *btcjson.WalletCreateFundedPsbtOpts, bip32Derivs *bool,
) (*btcjson.WalletCreateFundedPsbtResult, error) {
	return c.WalletCreateFundedPsbtAsync(ctx, inputs, outputs, locktime, options, bip32Derivs).Receive()
}

// FutureWalletProcessPsbtResult is a future promise to deliver the result of a
// WalletCreateFundedPsb RPC invocation (or an applicable error).
type FutureWalletProcessPsbtResult chan *Response

// Receive waits for the Response promised by the future and returns an updated
// PSBT with signed inputs from the wallet and a boolean indicating if the
// transaction has a complete set of signatures.
func (r FutureWalletProcessPsbtResult) Receive() (*btcjson.WalletProcessPsbtResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	// Unmarshal result as a getinfo result object.
	var psbtRes btcjson.WalletProcessPsbtResult
	err = json.Unmarshal(res, &psbtRes)
	if err != nil {
		return nil, err
	}

	return &psbtRes, nil
}

// WalletProcessPsbtAsync returns an instance of a type that can be used
// to get the result of the RPC at some future time by invoking the Receive
// function on the returned instance.
//
// See WalletProcessPsbt for the blocking version and more details.
func (c *Client) WalletProcessPsbtAsync(
	ctx context.Context, psbt string, sign *bool, sighashType SigHashType, bip32Derivs *bool,
) FutureWalletProcessPsbtResult {
	cmd := btcjson.NewWalletProcessPsbtCmd(psbt, sign, btcjson.String(sighashType.String()), bip32Derivs)
	return c.SendCmd(ctx, cmd)
}

// WalletProcessPsbt updates a PSBT with input information from our wallet and
// then signs inputs.
func (c *Client) WalletProcessPsbt(
	ctx context.Context, psbt string, sign *bool, sighashType SigHashType, bip32Derivs *bool,
) (*btcjson.WalletProcessPsbtResult, error) {
	return c.WalletProcessPsbtAsync(ctx, psbt, sign, sighashType, bip32Derivs).Receive()
}

// FutureGetWalletInfoResult is a future promise to deliver the result of an
// GetWalletInfoAsync RPC invocation (or an applicable error).
type FutureGetWalletInfoResult chan *Response

// Receive waits for the Response promised by the future and returns the result
// of wallet state info.
func (r FutureGetWalletInfoResult) Receive() (*btcjson.GetWalletInfoResult, error) {
	res, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var getWalletInfoResult btcjson.GetWalletInfoResult
	err = json.Unmarshal(res, &getWalletInfoResult)
	if err != nil {
		return nil, err
	}
	return &getWalletInfoResult, nil
}

// GetWalletInfoAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See GetWalletInfo for the blocking version and more details.
func (c *Client) GetWalletInfoAsync(ctx context.Context) FutureGetWalletInfoResult {
	cmd := btcjson.NewGetWalletInfoCmd()
	return c.SendCmd(ctx, cmd)
}

// GetWalletInfo returns various wallet state info.
func (c *Client) GetWalletInfo(ctx context.Context) (*btcjson.GetWalletInfoResult, error) {
	return c.GetWalletInfoAsync(ctx).Receive()
}

// FutureBackupWalletResult is a future promise to deliver the result of an
// BackupWalletAsync RPC invocation (or an applicable error)
type FutureBackupWalletResult chan *Response

// Receive waits for the Response promised by the future
func (r FutureBackupWalletResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// BackupWalletAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See BackupWallet for the blocking version and more details.
func (c *Client) BackupWalletAsync(ctx context.Context, destination string) FutureBackupWalletResult {
	return c.SendCmd(ctx, btcjson.NewBackupWalletCmd(destination))
}

// BackupWallet safely copies current wallet file to destination, which can
// be a directory or a path with filename
func (c *Client) BackupWallet(ctx context.Context, destination string) error {
	return c.BackupWalletAsync(ctx, destination).Receive()
}

// FutureDumpWalletResult is a future promise to deliver the result of an
// DumpWallet RPC invocation (or an applicable error)
type FutureDumpWalletResult chan *Response

// Receive waits for the Response promised by the future
func (r FutureDumpWalletResult) Receive() (*btcjson.DumpWalletResult, error) {
	bytes, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var res btcjson.DumpWalletResult
	err = json.Unmarshal(bytes, &res)
	return &res, err
}

// DumpWalletAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See DumpWalletAsync for the blocking version and more details.
func (c *Client) DumpWalletAsync(ctx context.Context, destination string) FutureDumpWalletResult {
	return c.SendCmd(ctx, btcjson.NewDumpWalletCmd(destination))
}

// DumpWallet dumps all wallet keys in a human-readable format to a server-side file.
func (c *Client) DumpWallet(ctx context.Context, destination string) (*btcjson.DumpWalletResult, error) {
	return c.DumpWalletAsync(ctx, destination).Receive()
}

// FutureImportWalletResult is a future promise to deliver the result of an
// ImportWalletAsync RPC invocation (or an applicable error)
type FutureImportWalletResult chan *Response

// Receive waits for the Response promised by the future
func (r FutureImportWalletResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// ImportWalletAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See ImportWallet for the blocking version and more details.
func (c *Client) ImportWalletAsync(ctx context.Context, filename string) FutureImportWalletResult {
	return c.SendCmd(ctx, btcjson.NewImportWalletCmd(filename))
}

// ImportWallet imports keys from a wallet dump file (see DumpWallet).
func (c *Client) ImportWallet(ctx context.Context, filename string) error {
	return c.ImportWalletAsync(ctx, filename).Receive()
}

// FutureUnloadWalletResult is a future promise to deliver the result of an
// UnloadWalletAsync RPC invocation (or an applicable error)
type FutureUnloadWalletResult chan *Response

// Receive waits for the Response promised by the future
func (r FutureUnloadWalletResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// UnloadWalletAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See UnloadWallet for the blocking version and more details.
func (c *Client) UnloadWalletAsync(ctx context.Context, walletName *string) FutureUnloadWalletResult {
	return c.SendCmd(ctx, btcjson.NewUnloadWalletCmd(walletName))
}

// UnloadWallet unloads the referenced wallet. If the RPC server URL already
// contains the name of the wallet, like http://127.0.0.1:8332/wallet/<walletname>,
// the parameter must be nil, or it'll return an error.
func (c *Client) UnloadWallet(ctx context.Context, walletName *string) error {
	return c.UnloadWalletAsync(ctx, walletName).Receive()
}

// FutureLoadWalletResult is a future promise to deliver the result of an
// LoadWalletAsync RPC invocation (or an applicable error)
type FutureLoadWalletResult chan *Response

// Receive waits for the Response promised by the future
func (r FutureLoadWalletResult) Receive() (*btcjson.LoadWalletResult, error) {
	bytes, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}
	var result btcjson.LoadWalletResult
	err = json.Unmarshal(bytes, &result)
	return &result, err
}

// LoadWalletAsync returns an instance of a type that can be used to get the result
// of the RPC at some future time by invoking the Receive function on the
// returned instance.
//
// See LoadWallet for the blocking version and more details.
func (c *Client) LoadWalletAsync(ctx context.Context, walletName string, loadOnStartup *bool) FutureLoadWalletResult {
	return c.SendCmd(ctx, btcjson.NewLoadWalletCmd(walletName, loadOnStartup))
}

// LoadWallet loads a wallet from a wallet file or directory.
// The loadOnStartup parameter is optional and controls whether the wallet should be loaded on startup.
func (c *Client) LoadWallet(ctx context.Context, walletName string, loadOnStartup *bool) (*btcjson.LoadWalletResult, error) {
	return c.LoadWalletAsync(ctx, walletName, loadOnStartup).Receive()
}

// FutureListWallets is a future promise to deliver the result of an
// ListWallets RPC invocation (or an applicable error)
type FutureListWalletsResult chan *Response

func (r FutureListWalletsResult) Receive() ([]string, error) {
	bytes, err := ReceiveFuture(r)
	if err != nil {
		return nil, err
	}

	var result []string
	return result, json.Unmarshal(bytes, &result)
}

func (c *Client) ListWalletsAsync(ctx context.Context) FutureListWalletsResult {
	return c.SendCmd(ctx, btcjson.NewListWalletsCmd())
}

func (c *Client) ListWallets(ctx context.Context) ([]string, error) {
	return c.ListWalletsAsync(ctx).Receive()
}

// TODO(davec): Implement
// encryptwallet (Won't be supported by btcwallet since it's always encrypted)
// listaddressgroupings (NYI in btcwallet)
// listreceivedbyaccount (NYI in btcwallet)
