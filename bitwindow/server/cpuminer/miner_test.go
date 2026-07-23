package cpuminer

import (
	"bytes"
	"encoding/json"
	"testing"
)

// Real segwit transaction from a drynet2 getblocktemplate response
// (July 2026); wtxid != txid since it carries witness data.
const (
	testSegwitTxData  = "0100000000010221423efa86bfdc44cfe3debb2b394201bc9cfe66e8dc5fa561bfb47accb5cbcb0100000000fdffffff5a93efa6a98f6a434de6634e6384e34e79cf54d177b443c215ed42e5131db7d31900000000fdffffff023e9a260000000000160014ff8cc6ab56a179e3d19d74f6d44306f41925ca90a2b4450000000000160014975632a1eeb008c571b124d7bad62ee8c97066b30247304402203692d5fbb6274b3ca271b5748c32c7c7d82f2763342a11824fd38cb60b87acb302206b33892d3cee7edd03acd2f6c9614df871de80c40e5681af639e0fa8a7c5d19601210252e462637b1688e2d51e7f21f4466234a3ebdf6b4bf1b8974b65b72de9d3c0c602483045022100c7ad408d94884b473825f43e24b550f0aaef775dd5cb845c6e889695ed3711a202206fd1f63bc4dfc7f10b5c11b0b7dd77266c9ece135dcb49f1556d8483aef75aed012102ef4335e6b9510a0998b0b1c1237e550ee1b9c28864bd71059418a58471a454b800000000"
	testSegwitTxTxid  = "6c805a9118aac81c5edd5ae50418d065cbbb7ebf7f2fe22d97ea8f9fb1bcaccd"
	testSegwitTxWtxid = "477de8c407b707dd36b70d8759558f62c7842e862b8dbc97fc7750e3012a8219"
)

// Regression test for the July 2026 drynet outage: GBT `rules` entries carry
// a "!" prefix when the rule is mandatory, so segwit arrives as "!segwit"
// (Bitcoin Core and the enforcer both emit that). The miner used to match
// only the literal "segwit", treated such templates as pre-segwit, and hashed
// the witness serialization of each transaction for the merkle leaves —
// yielding wtxids instead of txids, so every block containing a segwit
// transaction was rejected with bad-txnmrklroot.
func TestGbtWorkDecodeBangPrefixedSegwitRule(t *testing.T) {
	// Server-provided coinbase: only data (hex) and txid are consumed.
	const coinbaseTxid = "9d72a6f82b4ebe4447a5f21d596353514583abbebcf328b2fe5d6a0963c9b4e7"
	resp := gbtRpcResponse{
		PreviousBlockhash: "00000000407919cf7c93944ad2a1f52f0b1d1924124905b51a2f9ae43335d200",
		Bits:              "1d00ffff",
		Height:            958370,
		Curtime:           1784800000,
		Version:           0x20000000,
		Rules:             []string{"csv", "!segwit", "taproot"},
		Mutable:           []string{"time", "transactions", "prevblock"},
		Transactions: []gbtTransaction{
			{Data: testSegwitTxData, Txid: testSegwitTxTxid, Hash: testSegwitTxWtxid},
		},
		CoinbaseTxn: json.RawMessage(
			`{"data":"01000000","txid":"` + coinbaseTxid + `"}`,
		),
	}

	work, err := gbtWorkDecode(resp, "", "")
	if err != nil {
		t.Fatalf("gbtWorkDecode: %v", err)
	}

	// Expected merkle root: parent(coinbase txid, tx txid) — txids, never
	// wtxids, regardless of how the segwit rule is spelled.
	leaf := func(txidHex string) []byte {
		b := make([]byte, 32)
		if err := decodeHex(b, txidHex); err != nil {
			t.Fatalf("decode %s: %v", txidHex, err)
		}
		reverseBytes(b)
		return b
	}
	expected := make([]byte, 32)
	sha256d(expected, append(leaf(coinbaseTxid), leaf(testSegwitTxTxid)...))

	if !bytes.Equal(work.merkleroot[:], expected) {
		t.Fatalf(
			"merkle root built from wtxids, not txids (is the \"!segwit\" rule handled?)\n got: %x\nwant: %x",
			work.merkleroot[:], expected,
		)
	}
}
