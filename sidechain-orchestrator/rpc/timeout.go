package rpc

import "time"

// CallTimeout bounds one ordinary RPC. A node that accepts the connection and
// then answers nothing would otherwise hold the caller's goroutine for as long
// as the node runs.
const CallTimeout = 30 * time.Second

// ConnectBlockTimeout bounds connect_block, which stores the mainchain
// ancestors of the block inside the call and takes minutes on a node that was
// offline. It stays under one mainchain block: one goroutine drives every chain.
const ConnectBlockTimeout = 3 * time.Minute

// MethodTimeout returns the deadline one JSON-RPC method gets. Every sidechain
// transport reads this, so no chain gets a deadline of its own.
func MethodTimeout(method string) time.Duration {
	if method == "connect_block" {
		return ConnectBlockTimeout
	}
	return CallTimeout
}
