package engines

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

// Test vectors from https://gist.github.com/SamouraiDev/6aad669604c5930864bd
const (
	aliceSeedHex = "64dca76abc9c6f0cf3d212d248c380c4622c8f93b2c425ec6a5567fd5db57e10d3e6f94a2f6af4ac2edb8998072aad92098db73558c323777abf5bd1082d970a"
	bobSeedHex   = "87eaaac5a539ab028df44d9110defbef3797ddb805ca309f61a69ff96dbaa7ab5b24038cf029edec5235d933110f0aea8aeecf939ed14fc20730bba71e4b1110"
)

// stubBackend serves a fixed newest-first listtransactions history and records
// the skip offsets it was asked for. Unimplemented Backend methods panic.
type stubBackend struct {
	wallet.Backend
	chain wallet.ChainSource
	txs   []wallet.WalletTransaction
	skips []int
}

func (s *stubBackend) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]wallet.WalletTransaction, error) {
	s.skips = append(s.skips, skip)
	if skip >= len(s.txs) {
		return nil, nil
	}
	rows := s.txs[skip:]
	if count > 0 && count < len(rows) {
		rows = rows[:count]
	}
	return rows, nil
}

func (s *stubBackend) Chain() wallet.ChainSource { return s.chain }

type stubChain struct {
	wallet.ChainSource
	txs   map[string]*wallet.RawTransaction
	fetch int
}

func (s *stubChain) GetRawTransaction(ctx context.Context, txid string) (*wallet.RawTransaction, error) {
	s.fetch++
	tx, ok := s.txs[txid]
	if !ok {
		return nil, fmt.Errorf("no such tx %s", txid)
	}
	return tx, nil
}

// buildNotificationTx returns the raw notification tx Alice sends to the
// recipient's payment code, plus the listtransactions row for it.
func buildNotificationTx(t *testing.T, recipientSeedHex, notifAddr string) (wallet.WalletTransaction, *wallet.RawTransaction) {
	t.Helper()
	net := &chaincfg.MainNetParams

	sender, err := bip47.PaymentCodeFromSeed(aliceSeedHex, net)
	require.NoError(t, err)
	recipient, err := bip47.PaymentCodeFromSeed(recipientSeedHex, net)
	require.NoError(t, err)

	designatedPriv, _ := btcec.PrivKeyFromBytes(bytes.Repeat([]byte{0x11}, 32))
	const prevTxID = "86f411ab1c8e70ae8a0795ab7a6757aea6e4d5ae1826fc7b8f00c597d500609c"
	prevHash, err := chainhash.NewHashFromStr(prevTxID)
	require.NoError(t, err)

	senderSerialized := sender.Serialize()
	blinded, err := bip47.BuildBlindedPayload(senderSerialized, designatedPriv, recipient, wire.OutPoint{Hash: *prevHash, Index: 1})
	require.NoError(t, err)

	raw := &wallet.RawTransaction{
		TxID: "notification-txid",
		Vin: []wallet.RawTxIn{{
			TxID:    prevTxID,
			Vout:    1,
			Witness: []string{"3045sig", hex.EncodeToString(designatedPriv.PubKey().SerializeCompressed())},
		}},
		Vout: []wallet.RawTxOut{{
			ScriptPubKey: wallet.ScriptPubKey{
				Type: "nulldata",
				Hex:  hex.EncodeToString(append([]byte{0x6a, 0x4c, 0x50}, blinded[:]...)),
			},
		}},
		BlockTime: 1700000000,
	}
	row := wallet.WalletTransaction{TxID: raw.TxID, Category: "receive", Address: notifAddr, Confirmations: 3}
	return row, raw
}

// listtransactions counts skip from the newest entry, so a notification that
// arrives after a completed scan pass sits at offset 0 — the scanner must
// restart its pagination at 0 every pass or it never sees it.
func TestScanWalletFindsNotificationAfterCompletedPass(t *testing.T) {
	net := &chaincfg.MainNetParams
	const walletID = "W1"

	_, notifAddr, err := bip47.DeriveOwnNotificationKey(bobSeedHex, net)
	require.NoError(t, err)
	row, raw := buildNotificationTx(t, bobSeedHex, notifAddr.EncodeAddress())

	// History longer than one batch, so the pass pages more than once.
	history := make([]wallet.WalletTransaction, 0, bip47ListTxBatchSize+50)
	for i := 0; i < bip47ListTxBatchSize+50; i++ {
		history = append(history, wallet.WalletTransaction{
			TxID:     fmt.Sprintf("filler-%d", i),
			Category: "receive",
			Address:  "unrelated-address",
		})
	}

	chain := &stubChain{txs: map[string]*wallet.RawTransaction{raw.TxID: raw}}
	backend := &stubBackend{chain: chain, txs: history}
	store := bip47state.NewInboundStore(t.TempDir())
	e := NewBIP47Engine(zerolog.Nop(), nil, wallet.NewWalletEngine(nil, backend, func() *chaincfg.Params { return net }, zerolog.Nop()), store)

	require.NoError(t, e.scanWallet(context.Background(), walletID, bobSeedHex, net))

	// Notification arrives after that pass completed — newest first.
	backend.txs = append([]wallet.WalletTransaction{row}, history...)
	require.NoError(t, e.scanWallet(context.Background(), walletID, bobSeedHex, net))

	alice, err := bip47.PaymentCodeFromSeed(aliceSeedHex, net)
	require.NoError(t, err)
	got, err := store.Get(walletID, alice.Base58())
	require.NoError(t, err)
	require.NotNil(t, got, "notification arriving after a completed pass must still be recorded")
	require.Equal(t, raw.TxID, got.FirstNotificationTxID)
	require.Equal(t, int64(1700000000), got.FirstSeenBlockTime)

	// Both passes page from 0; no offset survives across passes.
	require.Equal(t, []int{0, bip47ListTxBatchSize, 0, bip47ListTxBatchSize}, backend.skips)

	// A further pass leaves the recorded notification alone — no second
	// getrawtransaction for it.
	require.NoError(t, e.scanWallet(context.Background(), walletID, bobSeedHex, net))
	require.Equal(t, 1, chain.fetch)
}

func TestParseOpReturnPayload_PushData1(t *testing.T) {
	// OP_RETURN OP_PUSHDATA1 0x50 <80 bytes of 0xAA>
	body := bytes.Repeat([]byte{0xAA}, 80)
	script := append([]byte{0x6a, 0x4c, 0x50}, body...)
	got, err := parseOpReturnPayload(script)
	require.NoError(t, err)
	require.Equal(t, body, got)
}

func TestParseOpReturnPayload_DirectPush(t *testing.T) {
	// OP_RETURN <0x05> <5 bytes> — payload < 76 bytes uses a direct push.
	body := []byte{1, 2, 3, 4, 5}
	script := append([]byte{0x6a, 0x05}, body...)
	got, err := parseOpReturnPayload(script)
	require.NoError(t, err)
	require.Equal(t, body, got)
}

func TestParseOpReturnPayload_RejectsNonOpReturn(t *testing.T) {
	_, err := parseOpReturnPayload([]byte{0x76, 0xa9})
	require.Error(t, err)
}

func TestParseOpReturnPayload_RejectsTruncated(t *testing.T) {
	_, err := parseOpReturnPayload([]byte{0x6a, 0x4c, 0x50, 0xAA}) // claims 80, has 1
	require.Error(t, err)
}

func TestPushedDataItems_TwoPushes(t *testing.T) {
	// P2PKH scriptSig: <sig 71 bytes> <pubkey 33 bytes>.
	sig := bytes.Repeat([]byte{0x01}, 71)
	pub := bytes.Repeat([]byte{0x02}, 33)
	var script []byte
	script = append(script, 0x47) // push 71
	script = append(script, sig...)
	script = append(script, 0x21) // push 33
	script = append(script, pub...)

	pushes, err := pushedDataItems(script)
	require.NoError(t, err)
	require.Len(t, pushes, 2)
	require.Equal(t, sig, pushes[0])
	require.Equal(t, pub, pushes[1])
}

func TestExtractInputPubKey_P2WPKH(t *testing.T) {
	// Witness stack [sig, pubkey] — return the second element parsed as pubkey.
	const pubHex = "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"
	witness := []string{"3045...sig", pubHex}
	pk, err := extractInputPubKey(witness, nil)
	require.NoError(t, err)
	require.Equal(t, pubHex, hex.EncodeToString(pk.SerializeCompressed()))
}

// TestExtractInputPubKey_RejectsEmptyInput proves the helper signals "no
// pubkey recoverable" so the designated-input loop in decodeNotificationTx
// can `continue` past P2SH/multisig inputs and try the next one.
func TestExtractInputPubKey_RejectsEmptyInput(t *testing.T) {
	_, err := extractInputPubKey(nil, nil)
	require.Error(t, err)
}

// Witness with a single element (e.g. a sweep with just a signature, no
// pubkey on the stack) is not a recoverable P2WPKH; the loop must skip it.
func TestExtractInputPubKey_RejectsSingleWitnessElement(t *testing.T) {
	_, err := extractInputPubKey([]string{"3045...sig"}, nil)
	require.Error(t, err)
}

func TestExtractInputPubKey_P2PKH(t *testing.T) {
	const pubHex = "0353883a146a23f988e0f381a9507cbdb3e3130cd81b3ce26daf2af088724ce683"
	pub, err := hex.DecodeString(pubHex)
	require.NoError(t, err)
	sig := bytes.Repeat([]byte{0x01}, 71)
	var script []byte
	script = append(script, 0x47)
	script = append(script, sig...)
	script = append(script, 0x21)
	script = append(script, pub...)

	scriptSig := &wallet.ScriptSig{Hex: hex.EncodeToString(script)}

	pk, err := extractInputPubKey(nil, scriptSig)
	require.NoError(t, err)
	require.Equal(t, pubHex, hex.EncodeToString(pk.SerializeCompressed()))
}
