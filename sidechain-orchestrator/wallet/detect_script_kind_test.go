package wallet

import (
	"context"
	"encoding/hex"
	"errors"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// usedAddressSource reports history for a fixed address set and records every
// address a probe asked about, so a test can pin the probe order.
type usedAddressSource struct {
	stubChainSource
	used    map[string]bool
	asked   []string
	failAll bool
}

func (s *usedAddressSource) AddressStats(_ context.Context, address string) (EsploraAddressStats, error) {
	s.asked = append(s.asked, address)
	if s.failAll {
		return EsploraAddressStats{}, errors.New("chain source unreachable")
	}
	if !s.used[address] {
		return EsploraAddressStats{Address: address}, nil
	}
	return EsploraAddressStats{Address: address, ChainStats: EsploraTxoStats{TxCount: 2}}, nil
}

// addressAt returns the address a bare key derives at index i on one branch
// under one script kind.
func addressAt(t *testing.T, xpub string, kind ScriptKind, change bool, i uint32, net *chaincfg.Params) string {
	t.Helper()
	d, err := ParseDescriptorAs(xpub, kind)
	require.NoError(t, err)
	ds, _, err := d.DeriveScript(change, i, net)
	require.NoError(t, err)
	return ds.address.EncodeAddress()
}

func legacyAccountXpub(t *testing.T) string {
	t.Helper()
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	acct, err := accountKeyFromSeed(seedHex, ScriptLegacy, &chaincfg.MainNetParams)
	require.NoError(t, err)
	return neuter(t, acct)
}

func detectBackend(t *testing.T, src ChainDataSource) *ElectrumBackend {
	t.Helper()
	return NewElectrumBackend(newTestService(t), src, StaticParams(&chaincfg.MainNetParams), zerolog.Nop())
}

// A Trezor legacy account exports a bare xpub. Its own history says legacy, so
// the import stops deriving bc1 addresses the wallet does not own.
func TestDetectScriptKindFindsTheUsedKind(t *testing.T) {
	net := &chaincfg.MainNetParams
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{addressAt(t, xpub, ScriptLegacy, false, 0, net): true}}
	kind, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	require.True(t, ok)
	assert.Equal(t, ScriptLegacy, kind)
}

// The probe walks index-major, so a wallet whose first address went unused is
// still placed rather than lost behind a full walk of the wrong kind.
func TestDetectScriptKindWalksIndexMajor(t *testing.T) {
	net := &chaincfg.MainNetParams
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{addressAt(t, xpub, ScriptLegacy, false, 3, net): true}}
	kind, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	require.True(t, ok)
	assert.Equal(t, ScriptLegacy, kind)

	// Every kind and branch at index 0 comes before anything at index 1.
	perIndex := len(detectScriptKinds) * 2
	require.Greater(t, len(src.asked), perIndex)
	assert.Equal(t, addressAt(t, xpub, ScriptNativeSegwit, false, 0, net), src.asked[0], "the most common kind goes first")
	assert.Equal(t, addressAt(t, xpub, ScriptNativeSegwit, true, 0, net), src.asked[1], "its change branch comes next")
	assert.Equal(t, addressAt(t, xpub, ScriptNativeSegwit, false, 1, net), src.asked[perIndex])
}

// Funds sent straight to an exported change address leave the receive branch
// untouched, and the key is still a used key.
func TestDetectScriptKindFindsHistoryOnTheChangeBranch(t *testing.T) {
	net := &chaincfg.MainNetParams
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{addressAt(t, xpub, ScriptLegacy, true, 2, net): true}}
	kind, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	require.True(t, ok)
	assert.Equal(t, ScriptLegacy, kind)
}

// A fresh key has no history, so nothing overrides the type the user picked.
func TestDetectScriptKindReportsNothingForAnUnusedKey(t *testing.T) {
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{}}
	_, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	assert.False(t, ok)
	assert.Len(t, src.asked, len(detectScriptKinds)*detectScanDepth*2, "both branches of every kind at every index, and no more")
}

// A dusted address under a second wrapper must not overrule the kind the user
// stated. Two kinds with history place nothing.
func TestDetectScriptKindRefusesAnAmbiguousKey(t *testing.T) {
	net := &chaincfg.MainNetParams
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{
		addressAt(t, xpub, ScriptLegacy, false, 1, net):       true,
		addressAt(t, xpub, ScriptNativeSegwit, false, 0, net): true,
	}}
	_, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	assert.False(t, ok)
}

// A lookup that fails leaves the walk incomplete. The import still keeps the
// chosen kind, and the failure reaches the log rather than passing as a clean
// "this key was never used".
func TestDetectScriptKindReportsNothingWhenEveryLookupFails(t *testing.T) {
	xpub := legacyAccountXpub(t)

	src := &usedAddressSource{used: map[string]bool{}, failAll: true}
	_, ok := detectBackend(t, src).DetectScriptKind(context.Background(), xpub)
	assert.False(t, ok)
	assert.Len(t, src.asked, len(detectScriptKinds)*detectScanDepth*2)
}

// Only a key that states no type needs the chain probed.
func TestBareKeyWithoutKind(t *testing.T) {
	xpub := legacyAccountXpub(t)

	assert.True(t, BareKeyWithoutKind(xpub))
	assert.False(t, BareKeyWithoutKind("[d34db33f/44'/0'/0']"+xpub), "an origin purpose states the type")
	assert.False(t, BareKeyWithoutKind("pkh("+xpub+"/0/*)"), "a script wrapper states the type")
	assert.False(t, BareKeyWithoutKind(""))
}
