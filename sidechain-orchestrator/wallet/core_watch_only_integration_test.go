//go:build integration

package wallet_test

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/testharness"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// Core reads more policies than the parser. An old watch-only wallet with
// wsh(multi(...)) loads into Core, and Core keeps the sequence of its keys.
func TestCoreWatchOnlyKeepsAPolicyTheParserRejects(t *testing.T) {
	h := testharness.New(t, 1)
	defer h.Close()
	node := h.Nodes[0]
	net := &chaincfg.RegressionNetParams

	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Minute)
	defer cancel()

	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	var keys []*hdkeychain.ExtendedKey
	var pubs [][]byte
	for _, passphrase := range []string{"", "second"} {
		master, err := hdkeychain.NewMaster(wallet.MnemonicToSeed(mnemonic, passphrase), net)
		require.NoError(t, err)
		key, err := master.Neuter()
		require.NoError(t, err)
		child, err := key.Derive(0)
		require.NoError(t, err)
		child, err = child.Derive(0)
		require.NoError(t, err)
		pub, err := child.ECPubKey()
		require.NoError(t, err)
		keys = append(keys, key)
		pubs = append(pubs, pub.SerializeCompressed())
	}
	// Out of sorted sequence, so a sortedmulti import gives another address.
	if bytes.Compare(pubs[0], pubs[1]) < 0 {
		keys[0], keys[1] = keys[1], keys[0]
		pubs[0], pubs[1] = pubs[1], pubs[0]
	}
	multi := "wsh(multi(1," + keys[0].String() + "/0/*," + keys[1].String() + "/0/*))"

	dir := t.TempDir()
	body, err := json.Marshal(map[string]any{
		"wallets": []map[string]any{
			{"id": "WATCHMULTI", "name": "Watch", "wallet_type": "bitcoinCore", "watch_only": map[string]string{"descriptor": multi}},
		},
		"activeWalletId": "WATCHMULTI",
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), body, 0o600))
	svc := wallet.NewService(dir, zerolog.Nop())
	require.NoError(t, svc.Init())
	defer svc.Close()

	backend := wallet.NewCoreBackend(svc, node.CoreRPC, wallet.StaticParams(net), zerolog.Nop())
	name, err := backend.Ensure(ctx, "WATCHMULTI")
	require.NoError(t, err)
	got, err := node.CoreRPC.GetNewAddress(ctx, name, "", "bech32")
	require.NoError(t, err)

	var given []*btcutil.AddressPubKey
	for _, pub := range pubs {
		a, err := btcutil.NewAddressPubKey(pub, net)
		require.NoError(t, err)
		given = append(given, a)
	}
	script, err := txscript.MultiSigScript(given, 1)
	require.NoError(t, err)
	hash := sha256.Sum256(script)
	want, err := btcutil.NewAddressWitnessScriptHash(hash[:], net)
	require.NoError(t, err)
	require.Equal(t, want.EncodeAddress(), got)
}
