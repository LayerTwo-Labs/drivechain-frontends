// Copyright (c) 2014-2017 The btcsuite developers
// Copyright (c) 2015-2017 The Decred developers
// Use of this source code is governed by an ISC
// license that can be found in the LICENSE file.

package rpcclient

// FutureNotifySpentResult is a future promise to deliver the result of a
// NotifySpentAsync RPC invocation (or an applicable error).
//
// Deprecated: Use FutureLoadTxFilterResult instead.
type FutureNotifySpentResult chan *Response

// Receive waits for the Response promised by the future and returns an error
// if the registration was not successful.
func (r FutureNotifySpentResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// FutureNotifyNewTransactionsResult is a future promise to deliver the result
// of a NotifyNewTransactionsAsync RPC invocation (or an applicable error).
type FutureNotifyNewTransactionsResult chan *Response

// Receive waits for the Response promised by the future and returns an error
// if the registration was not successful.
func (r FutureNotifyNewTransactionsResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// FutureNotifyReceivedResult is a future promise to deliver the result of a
// NotifyReceivedAsync RPC invocation (or an applicable error).
//
// Deprecated: Use FutureLoadTxFilterResult instead.
type FutureNotifyReceivedResult chan *Response

// Receive waits for the Response promised by the future and returns an error
// if the registration was not successful.
func (r FutureNotifyReceivedResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}

// FutureRescanResult is a future promise to deliver the result of a RescanAsync
// or RescanEndHeightAsync RPC invocation (or an applicable error).
//
// Deprecated: Use FutureRescanBlocksResult instead.
type FutureRescanResult chan *Response

// Receive waits for the Response promised by the future and returns an error
// if the rescan was not successful.
func (r FutureRescanResult) Receive() error {
	_, err := ReceiveFuture(r)
	return err
}
