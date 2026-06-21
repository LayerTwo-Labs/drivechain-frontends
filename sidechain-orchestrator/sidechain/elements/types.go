// Package elements provides a JSON-RPC client for the Elements/Liquid sidechain.
//
// Unlike the CUSF sidechains (thunder, zside, …) which speak their own
// unauthenticated JSON-RPC, Elements is a Bitcoin Core derivative: the RPC is
// HTTP basic-auth'd (rpcuser/rpcpassword or the datadir .cookie) and the method
// surface is the Bitcoin Core one (getnewaddress, getbalance, getblockcount …).
package elements

// BalanceResponse normalises an Elements wallet balance into sats so it lines
// up with the other sidechain clients' BalanceResponse.
//
// NOTE: `getbalance` on Elements returns a map keyed by asset label (e.g.
// {"bitcoin": 1.23}) on a multi-asset chain, or a bare number on a single-asset
// chain. The contributor must decide which asset to surface. See client.go.
type BalanceResponse struct {
	TotalSats     int64 `json:"total_sats"`
	AvailableSats int64 `json:"available_sats"`
}
