package bip47send

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// Samourai BIP47 vectors. Mirrors the constants in the bip47 package's
// vectors_test.go so we can drive the integration end-to-end here too.
const (
	aliceSeedHex = "64dca76abc9c6f0cf3d212d248c380c4622c8f93b2c425ec6a5567fd5db57e10d3e6f94a2f6af4ac2edb8998072aad92098db73558c323777abf5bd1082d970a"
	bobPM        = "PM8TJS2JxQ5ztXUpBBRnpTbcUXbUHy2T1abfrb3KkAAtMEGNbey4oumH7Hc578WgQJhPjBxteQ5GHHToTYHE3A1w6p7tU6KSoFmWBVbFGjKPisZDbP97"
	// The designated outpoint from the vectors: txid (BE) + vout (LE) = 36
	// bytes serialized. Wire form is hash + uint32 LE; the hex below already
	// has the hash little-endian as it appears on the wire.
	designatedOutpointHex = "86f411ab1c8e70ae8a0795ab7a6757aea6e4d5ae1826fc7b8f00c597d500609c01000000"
	designatedInputWIF    = "Kx983SRhAZpAhj7Aac1wUXMJ6XZeyJKqCxJJ49dxEbYCT4a1ozRD"
	aliceBlindedPayload   = "010002063e4eb95e62791b06c50e1a3a942e1ecaaa9afbbeb324d16ae6821e091611fa96c0cf048f607fe51a0327f5e2528979311c78cb2de0d682c61e1180fc3d543b00000000000000000000000000"
)

func wireOutpointFromHex(t *testing.T, s string) wire.OutPoint {
	t.Helper()
	b, err := hex.DecodeString(s)
	require.NoError(t, err)
	require.Len(t, b, 36)
	var h chainhash.Hash
	copy(h[:], b[:32])
	idx := uint32(b[32]) | uint32(b[33])<<8 | uint32(b[34])<<16 | uint32(b[35])<<24
	return wire.OutPoint{Hash: h, Index: idx}
}

func designatedPriv(t *testing.T) *btcec.PrivateKey {
	t.Helper()
	wif, err := btcutil.DecodeWIF(designatedInputWIF)
	require.NoError(t, err)
	return wif.PrivKey
}

func TestBuildNotificationTx_OpReturnMatchesVector(t *testing.T) {
	recipient, err := bip47.ParsePaymentCode(bobPM)
	require.NoError(t, err)

	outp := wireOutpointFromHex(t, designatedOutpointHex)

	// Reverse the wire-form txid hash to RPC string form (big-endian).
	var rpcTxIDBytes [32]byte
	for i := 0; i < 32; i++ {
		rpcTxIDBytes[i] = outp.Hash[31-i]
	}

	desig := DesignatedInput{
		TxID:       hex.EncodeToString(rpcTxIDBytes[:]),
		Vout:       outp.Index,
		AmountSats: 100_000,
	}

	// Use the wallet's notification address for both notification and change
	// so we don't drag in extra moving parts.
	notifAddr, err := bip47.DeriveNotificationAddress(recipient, &chaincfg.MainNetParams)
	require.NoError(t, err)
	changeAddr := notifAddr // doesn't affect the OP_RETURN

	rawHex, gotOutpoint, err := BuildNotificationTx(
		aliceSeedHex,
		recipient,
		desig,
		designatedPriv(t),
		notifAddr,
		changeAddr,
		546,
		1000,
		&chaincfg.MainNetParams,
	)
	require.NoError(t, err)
	assert.Equal(t, outp, gotOutpoint)

	rawBytes, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	var msgTx wire.MsgTx
	require.NoError(t, msgTx.Deserialize(strings.NewReader(string(rawBytes))))

	// Find OP_RETURN output.
	var opReturnPayload []byte
	for _, out := range msgTx.TxOut {
		// Detect OP_RETURN (0x6a) followed by PUSHDATA1 0x50 (=80) bytes.
		if len(out.PkScript) >= 2 && out.PkScript[0] == 0x6a {
			// txscript.NullDataScript with 80 bytes uses OP_RETURN OP_PUSHDATA1 0x50 <80 bytes>
			if out.PkScript[1] == 0x4c && len(out.PkScript) == 83 {
				opReturnPayload = out.PkScript[3:]
				break
			}
		}
	}
	require.NotNil(t, opReturnPayload, "no OP_RETURN with 80-byte payload found")
	assert.Equal(t, aliceBlindedPayload, hex.EncodeToString(opReturnPayload))
}

func TestDerivePrivKeyFromHDPath(t *testing.T) {
	// Sanity-check that deriving the same path twice gives the same key, and
	// distinct paths give distinct keys. The exact key matters in production
	// only relative to Core's getaddressinfo output, which we don't mock here.
	a, err := DerivePrivKeyFromHDPath(aliceSeedHex, "m/84'/0'/0'/0/0")
	require.NoError(t, err)
	b, err := DerivePrivKeyFromHDPath(aliceSeedHex, "m/84'/0'/0'/0/0")
	require.NoError(t, err)
	assert.Equal(t, a.Serialize(), b.Serialize())

	c, err := DerivePrivKeyFromHDPath(aliceSeedHex, "m/84'/0'/0'/0/1")
	require.NoError(t, err)
	assert.NotEqual(t, a.Serialize(), c.Serialize())
}

// fakeReserver is an in-memory IndexReserver for substitution tests.
type fakeReserver struct {
	counters map[string]uint32
}

func (f *fakeReserver) ReserveNextIndex(walletID, code string) (uint32, error) {
	if f.counters == nil {
		f.counters = map[string]uint32{}
	}
	k := walletID + "\x00" + code
	idx := f.counters[k]
	f.counters[k] = idx + 1
	return idx, nil
}

// First 10 P2PKH addresses Alice → Bob from the Samourai vectors.
var aliceToBobAddresses = [10]string{
	"141fi7TY3h936vRUKh1qfUZr8rSBuYbVBK",
	"12u3Uued2fuko2nY4SoSFGCoGLCBUGPkk6",
	"1FsBVhT5dQutGwaPePTYMe5qvYqqjxyftc",
	"1CZAmrbKL6fJ7wUxb99aETwXhcGeG3CpeA",
	"1KQvRShk6NqPfpr4Ehd53XUhpemBXtJPTL",
	"1KsLV2F47JAe6f8RtwzfqhjVa8mZEnTM7t",
	"1DdK9TknVwvBrJe7urqFmaxEtGF2TMWxzD",
	"16DpovNuhQJH7JUSZQFLBQgQYS4QB9Wy8e",
	"17qK2RPGZMDcci2BLQ6Ry2PDGJErrNojT5",
	"1GxfdfP286uE24qLZ9YRP3EWk2urqXgC4s",
}

func TestSubstituteBip47Destination_AlignsWithVectors(t *testing.T) {
	reserver := &fakeReserver{}
	dest := map[string]int64{bobPM: 100_000}

	r, err := SubstituteBip47Destination(aliceSeedHex, "w1", dest, &chaincfg.MainNetParams, reserver)
	require.NoError(t, err)
	require.True(t, r.IsBip47)
	require.Equal(t, bobPM, r.RecipientCode)
	require.Equal(t, uint32(0), r.Index)
	require.Len(t, r.Destinations, 1)

	for addr, sats := range r.Destinations {
		assert.Equal(t, aliceToBobAddresses[0], addr)
		assert.Equal(t, int64(100_000), sats)
	}

	// Second call advances the index to 1 and produces the next vector address.
	r2, err := SubstituteBip47Destination(aliceSeedHex, "w1", dest, &chaincfg.MainNetParams, reserver)
	require.NoError(t, err)
	require.Equal(t, uint32(1), r2.Index)
	for addr := range r2.Destinations {
		assert.Equal(t, aliceToBobAddresses[1], addr)
	}
}

func TestSubstituteBip47Destination_PassthroughForNonBip47(t *testing.T) {
	reserver := &fakeReserver{}
	dest := map[string]int64{
		"1BoatSLRHtKNngkdXEeobR76b53LETtpyT": 100_000,
	}
	r, err := SubstituteBip47Destination(aliceSeedHex, "w1", dest, &chaincfg.MainNetParams, reserver)
	require.NoError(t, err)
	assert.False(t, r.IsBip47)
	assert.Equal(t, dest, r.Destinations)
}

func TestSubstituteBip47Destination_RejectsMultiDestination(t *testing.T) {
	reserver := &fakeReserver{}
	dest := map[string]int64{
		bobPM: 100_000,
		"1BoatSLRHtKNngkdXEeobR76b53LETtpyT": 50_000,
	}
	_, err := SubstituteBip47Destination(aliceSeedHex, "w1", dest, &chaincfg.MainNetParams, reserver)
	require.ErrorIs(t, err, ErrMultiDestination)
}

func TestSubstituteBip47Destination_RejectsSelfSend(t *testing.T) {
	reserver := &fakeReserver{}
	// Alice's own payment code from the vectors.
	const alicePM = "PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA"
	dest := map[string]int64{alicePM: 100_000}
	_, err := SubstituteBip47Destination(aliceSeedHex, "w1", dest, &chaincfg.MainNetParams, reserver)
	require.ErrorIs(t, err, ErrSelfSend)
}

func TestNetworkParams(t *testing.T) {
	for _, net := range []string{"mainnet", "signet", "regtest"} {
		t.Run(net, func(t *testing.T) {
			p, err := NetworkParams(net)
			require.NoError(t, err)
			assert.NotNil(t, p)
		})
	}

	_, err := NetworkParams("testnet")
	assert.Error(t, err)
}
