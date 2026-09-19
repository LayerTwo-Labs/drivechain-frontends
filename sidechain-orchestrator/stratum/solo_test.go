package stratum_test

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"net"
	"sync"
	"testing"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/stratum"
)

// A segwit transaction from a drynet2 block template.
const (
	segwitTxData = "0100000000010221423efa86bfdc44cfe3debb2b394201bc9cfe66e8dc5fa561bfb47accb5cbcb0100000000fdffffff5a93efa6a98f6a434de6634e6384e34e79cf54d177b443c215ed42e5131db7d31900000000fdffffff023e9a260000000000160014ff8cc6ab56a179e3d19d74f6d44306f41925ca90a2b4450000000000160014975632a1eeb008c571b124d7bad62ee8c97066b30247304402203692d5fbb6274b3ca271b5748c32c7c7d82f2763342a11824fd38cb60b87acb302206b33892d3cee7edd03acd2f6c9614df871de80c40e5681af639e0fa8a7c5d19601210252e462637b1688e2d51e7f21f4466234a3ebdf6b4bf1b8974b65b72de9d3c0c602483045022100c7ad408d94884b473825f43e24b550f0aaef775dd5cb845c6e889695ed3711a202206fd1f63bc4dfc7f10b5c11b0b7dd77266c9ece135dcb49f1556d8483aef75aed012102ef4335e6b9510a0998b0b1c1237e550ee1b9c28864bd71059418a58471a454b800000000"
	segwitTxid   = "6c805a9118aac81c5edd5ae50418d065cbbb7ebf7f2fe22d97ea8f9fb1bcaccd"
	prevBlock    = "00000000407919cf7c93944ad2a1f52f0b1d1924124905b51a2f9ae43335d200"
	rewardSats   = 50_0000_0000
)

// segwitTemplate builds a template the way the enforcer serves one: a
// coinbase with a BIP34 height, a payout, and a witness commitment.
func segwitTemplate(t *testing.T, height uint32, extraScriptSig []byte) stratum.Template {
	t.Helper()
	raw, err := hex.DecodeString(segwitTxData)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	scriptSig, err := txscript.NewScriptBuilder().AddInt64(int64(height)).AddData(extraScriptSig).Script()
	require.NoError(t, err)
	coinbase := wire.NewMsgTx(2)
	coinbase.AddTxIn(&wire.TxIn{
		PreviousOutPoint: wire.OutPoint{Index: wire.MaxPrevOutIndex},
		SignatureScript:  scriptSig,
		Sequence:         wire.MaxTxInSequenceNum,
		Witness:          wire.TxWitness{make([]byte, 32)},
	})
	payout, err := hex.DecodeString("0014ff8cc6ab56a179e3d19d74f6d44306f41925ca90")
	require.NoError(t, err)
	coinbase.AddTxOut(wire.NewTxOut(rewardSats, payout))

	witnessRoot := blockchain.CalcMerkleRoot([]*btcutil.Tx{btcutil.NewTx(coinbase), btcutil.NewTx(&tx)}, true)
	commitment := chainhash.DoubleHashB(append(witnessRoot[:], make([]byte, 32)...))
	commitmentScript := append([]byte{txscript.OP_RETURN, 0x24, 0xaa, 0x21, 0xa9, 0xed}, commitment...)
	coinbase.AddTxOut(wire.NewTxOut(0, commitmentScript))

	var buf bytes.Buffer
	require.NoError(t, coinbase.Serialize(&buf))
	return stratum.Template{
		Version:           0x20000000,
		PreviousBlockHash: prevBlock,
		Transactions:      []stratum.TemplateTransaction{{Data: segwitTxData, Txid: segwitTxid}},
		CoinbaseTxn:       &stratum.TemplateTransaction{Data: hex.EncodeToString(buf.Bytes())},
		Bits:              "207fffff",
		Height:            height,
		CurTime:           uint32(time.Now().Add(-time.Minute).Unix()),
	}
}

type fakeNode struct {
	template stratum.Template
	mu       sync.Mutex
	blocks   [][]byte
	got      chan struct{}
}

func (n *fakeNode) GetBlockTemplate(context.Context) (stratum.Template, error) {
	return n.template, nil
}

func (n *fakeNode) SubmitBlock(_ context.Context, block []byte, _ string) error {
	n.mu.Lock()
	n.blocks = append(n.blocks, block)
	n.mu.Unlock()
	n.got <- struct{}{}
	return nil
}

func TestNewSoloWork(t *testing.T) {
	template := segwitTemplate(t, 958370, nil)
	w, err := stratum.NewSoloWork(template)
	require.NoError(t, err)

	t.Run("the extranonce sits at the end of the scriptSig", func(t *testing.T) {
		coinbase := append(append(append([]byte{}, w.Coinb1...), bytes.Repeat([]byte{0xab}, 12)...), w.Coinb2...)
		var tx wire.MsgTx
		require.NoError(t, tx.DeserializeNoWitness(bytes.NewReader(coinbase)))
		script := tx.TxIn[0].SignatureScript
		height, err := txscript.NewScriptBuilder().AddInt64(958370).Script()
		require.NoError(t, err)
		assert.True(t, bytes.HasPrefix(script, height))
		assert.Equal(t, append([]byte{txscript.OP_DATA_12}, bytes.Repeat([]byte{0xab}, 12)...), script[len(script)-13:])
		assert.Len(t, tx.TxOut, 2)
	})

	t.Run("work fields", func(t *testing.T) {
		assert.Equal(t, 12, w.ExtranonceSize)
		assert.Equal(t, uint32(958370), w.Height)
		assert.Equal(t, int64(rewardSats), w.RewardSats)
		assert.Equal(t, uint32(0x207fffff), w.Bits)
		assert.Equal(t, prevBlock, w.PrevHash.String())
		require.Len(t, w.Branch, 1)
		assert.Equal(t, segwitTxid, w.Branch[0].String())
	})

	t.Run("a scriptSig with no room for the extranonce", func(t *testing.T) {
		_, err := stratum.NewSoloWork(segwitTemplate(t, 958370, make([]byte, 90)))
		require.ErrorContains(t, err, "limit is 100")
	})

	t.Run("a template with no coinbasetxn", func(t *testing.T) {
		template := segwitTemplate(t, 958370, nil)
		template.CoinbaseTxn = nil
		_, err := stratum.NewSoloWork(template)
		require.Error(t, err)
	})
}

func serve(t *testing.T, source stratum.Source) (*stratum.Server, string, <-chan error) {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	server := stratum.NewServer(source, zerolog.Nop())
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan error, 1)
	go func() { done <- server.Serve(ctx, ln) }()
	t.Cleanup(func() {
		cancel()
		<-done
	})
	return server, ln.Addr().String(), done
}

func TestSoloEndToEnd(t *testing.T) {
	node := &fakeNode{template: segwitTemplate(t, 500, []byte("enforcer")), got: make(chan struct{}, 4)}
	source, err := stratum.NewSoloSource(context.Background(), node, zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, source)

	miner := dialMiner(t, addr)
	miner.start("avalon.1")
	assert.Len(t, miner.extranonce1, 4)
	assert.Equal(t, 8, miner.extranonce2Size)

	j := parseJob(t, miner.next("mining.notify"))
	// Regtest bits put the network difficulty under the floor, so the
	// server holds the share difficulty there.
	assert.InDelta(t, stratum.NetworkDifficulty(0x207fffff), miner.difficulty, 1e-18)

	const versionBits = 0x04000000
	extranonce2 := []byte{1, 2, 3, 4, 5, 6, 7, 8}
	found := grind(t, miner, j, extranonce2, versionBits, miner.difficulty)
	reply := miner.submit("avalon.1", j, found, versionBits)
	require.Equal(t, "true", string(reply.Result))

	select {
	case <-node.got:
	case <-time.After(10 * time.Second):
		t.Fatal("the node got no block")
	}
	node.mu.Lock()
	raw := node.blocks[0]
	node.mu.Unlock()

	var block wire.MsgBlock
	require.NoError(t, block.Deserialize(bytes.NewReader(raw)))
	assert.Equal(t, found.header.BlockHash(), block.BlockHash())
	assert.Equal(t, int32(0x20000000|versionBits), block.Header.Version)
	require.Len(t, block.Transactions, 2)

	txs := []*btcutil.Tx{btcutil.NewTx(block.Transactions[0]), btcutil.NewTx(block.Transactions[1])}
	assert.Equal(t, blockchain.CalcMerkleRoot(txs, false), block.Header.MerkleRoot)
	require.NoError(t, blockchain.ValidateWitnessCommitment(btcutil.NewBlock(&block)))

	coinbase := block.Transactions[0]
	assert.Equal(t, wire.TxWitness{make([]byte, 32)}, coinbase.TxIn[0].Witness)
	script := coinbase.TxIn[0].SignatureScript
	assert.Equal(t, append(append([]byte{}, miner.extranonce1...), extranonce2...), script[len(script)-12:])
	assert.Equal(t, segwitTxid, block.Transactions[1].TxHash().String())

	require.Eventually(t, func() bool { return len(server.Status().Blocks) == 1 }, 5*time.Second, 10*time.Millisecond)
	status := server.Status()
	assert.Equal(t, uint32(500), status.Blocks[0].Height)
	assert.Equal(t, int64(rewardSats), status.Blocks[0].RewardSats)
	assert.Equal(t, "avalon.1", status.Blocks[0].Worker)
	assert.Equal(t, block.BlockHash(), status.Blocks[0].Hash)
	require.Len(t, status.Miners, 1)
	assert.Equal(t, "avalon.1", status.Miners[0].Worker)
	assert.Equal(t, "127.0.0.1", status.Miners[0].Address)
	assert.Equal(t, uint64(1), status.Miners[0].Accepted)

	t.Run("the same share again is a duplicate", func(t *testing.T) {
		reply := miner.submit("avalon.1", j, found, versionBits)
		assert.JSONEq(t, `[22, "duplicate share", null]`, string(reply.Error))
	})

	t.Run("an unknown job is stale", func(t *testing.T) {
		stale := j
		stale.id = "ffff"
		reply := miner.submit("avalon.1", stale, found, versionBits)
		assert.JSONEq(t, `[21, "job not found", null]`, string(reply.Error))
	})

	t.Run("version bits outside the mask", func(t *testing.T) {
		other := grind(t, miner, j, []byte{9, 9, 9, 9, 9, 9, 9, 9}, 0, miner.difficulty)
		reply := miner.submit("avalon.1", j, other, 0x00000100)
		assert.Contains(t, string(reply.Error), "outside the mask")
	})

	t.Run("an ntime before the job", func(t *testing.T) {
		early := j
		early.ntime = j.ntime - 1
		other := grind(t, miner, early, []byte{8, 8, 8, 8, 8, 8, 8, 8}, 0, miner.difficulty)
		reply := miner.submit("avalon.1", early, other, 0)
		assert.JSONEq(t, `[20, "ntime out of range", null]`, string(reply.Error))
	})
}

func TestSoloLowDifficultyShare(t *testing.T) {
	template := segwitTemplate(t, 500, nil)
	template.Bits = "1d00ffff"
	node := &fakeNode{template: template, got: make(chan struct{}, 4)}
	source, err := stratum.NewSoloSource(context.Background(), node, zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, source)

	miner := dialMiner(t, addr)
	miner.start("avalon.1")
	j := parseJob(t, miner.next("mining.notify"))
	assert.Equal(t, float64(1), miner.difficulty)

	// A header that meets difficulty 2^-20 but, in all odds, not difficulty 1.
	weak := grind(t, miner, j, make([]byte, 8), 0, 1.0/(1<<20))
	hash := weak.header.BlockHash()
	if blockchain.HashToBig(&hash).Cmp(blockchain.CompactToBig(0x1d00ffff)) <= 0 {
		t.Skip("the weak share met difficulty 1")
	}
	reply := miner.submit("avalon.1", j, weak, 0)
	assert.JSONEq(t, `[23, "low difficulty share", null]`, string(reply.Error))
	assert.Equal(t, uint64(1), server.Status().Rejected)
}

type failingNode struct{ fakeNode }

var errTemplate = errors.New("the node is still syncing")

func (n *failingNode) GetBlockTemplate(context.Context) (stratum.Template, error) {
	return stratum.Template{}, errTemplate
}

func TestNewSoloSourceNeedsATemplate(t *testing.T) {
	_, err := stratum.NewSoloSource(context.Background(), &failingNode{}, zerolog.Nop())
	require.ErrorIs(t, err, errTemplate)
}
