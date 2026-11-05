package engines

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sync"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

type chequeAccounts struct {
	orchrpc.WalletManagerServiceClient
	wallets []*orchpb.WalletMetadata
}

func (c chequeAccounts) ListWallets(context.Context, *orchpb.ListWalletsRequest) (*orchpb.ListWalletsResponse, error) {
	return &orchpb.ListWalletsResponse{Wallets: c.wallets}, nil
}

func chequeKeyBytes(t *testing.T, engine *ChequeEngine, cheque *cheques.Cheque) []byte {
	t.Helper()
	key, err := engine.ChequePrivateKey(t.Context(), cheque)
	require.NoError(t, err)
	wif, err := btcutil.DecodeWIF(key)
	require.NoError(t, err)
	return wif.PrivKey.Serialize()
}

func TestChequeKeysUseSeparateNetworks(t *testing.T) {
	keys := make(map[string]string)
	for _, test := range []struct {
		scope  string
		params *chaincfg.Params
	}{
		{"mainnet/", &chaincfg.MainNetParams},
		{"testnet/", &chaincfg.TestNet3Params},
		{"signet/", &chaincfg.SigNetParams},
		{"regtest/", &chaincfg.RegressionNetParams},
		{"ecash/first", &chaincfg.MainNetParams},
		{"ecash/second", &chaincfg.MainNetParams},
	} {
		t.Run(test.scope, func(t *testing.T) {
			engine := testChequeEngine(t, &fakeChain{})
			engine.network, engine.chainParams = test.scope, test.params
			cheque, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
			require.NoError(t, err)
			key := string(chequeKeyBytes(t, engine, cheque))
			require.Empty(t, keys[key], "key also belongs to %s", keys[key])
			keys[key] = test.scope
			require.Equal(t, uint32(1), cheque.KeyVersion)
			require.Len(t, cheque.KeyDomain, 64)
		})
	}
}

func TestChequeKeysUseAccountPaths(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	wallets := []*orchpb.WalletMetadata{
		{Id: "first"},
		{Id: "second", AccountIndex: 1},
		{Id: "third", DerivationPath: "m/84'/1'/2'"},
		{Id: "same", DerivationPath: "84h/1h/0h"},
	}
	engine.walletEngine.orchClient = chequeAccounts{engine.walletEngine.orchClient, wallets}
	var first *cheques.Cheque
	keys := make(map[string]bool)
	for _, wallet := range wallets {
		cheque, err := engine.CreateCheque(t.Context(), wallet.Id, 1000)
		require.NoError(t, err)
		key := string(chequeKeyBytes(t, engine, cheque))
		require.False(t, keys[key])
		keys[key] = true
		switch {
		case first == nil:
			first = cheque
		case wallet.Id == "same":
			require.Equal(t, first.KeyDomain, cheque.KeyDomain)
			require.Equal(t, uint32(1), cheque.DerivationIndex)
		default:
			require.NotEqual(t, first.KeyDomain, cheque.KeyDomain)
			require.Zero(t, cheque.DerivationIndex)
		}
		require.NoError(t, cheques.Delete(t.Context(), engine.db, wallet.Id, cheque.ID))
	}
}

func TestChequeKeysShareCounterAcrossRequests(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	var wg sync.WaitGroup
	rows := make(chan *cheques.Cheque, 8)
	errs := make(chan error, 8)
	for range 8 {
		wg.Go(func() {
			row, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
			rows <- row
			errs <- err
		})
	}
	wg.Wait()
	close(rows)
	close(errs)
	for err := range errs {
		require.NoError(t, err)
	}
	indices := map[uint32]bool{}
	for row := range rows {
		require.False(t, indices[row.DerivationIndex])
		indices[row.DerivationIndex] = true
	}
	require.Len(t, indices, 8)
}

func TestChequeKeysKeepLegacyAccess(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	oldKey, err := engine.DeriveChequePrivateKey(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	oldAddress, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	id, err := cheques.Create(t.Context(), engine.db, chequeWalletID, 0, 1000, oldAddress)
	require.NoError(t, err)
	legacy, err := cheques.Get(t.Context(), engine.db, chequeWalletID, id)
	require.NoError(t, err)
	got, err := engine.ChequePrivateKey(t.Context(), legacy)
	require.NoError(t, err)
	require.Equal(t, oldKey, got)
	current, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.Zero(t, current.DerivationIndex)
	require.NotEqual(t, chequeKeyBytes(t, engine, legacy), chequeKeyBytes(t, engine, current))
	current.KeyScope = "regtest/"
	_, err = engine.ChequePrivateKey(t.Context(), current)
	require.ErrorContains(t, err, "key domain does not match")
}

func TestChequeKeysRecoverBothVersions(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)
	legacy, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	current, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(t.Context(), engine.db, chequeWalletID, current.ID))
	chain.funded[legacy], chain.funded[current.Address] = testUTXOs(), testUTXOs()
	engine.recoverChequesOnUnlock(t.Context())
	rows, err := cheques.List(t.Context(), engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Len(t, rows, 2)
	for _, row := range rows {
		key, err := engine.ChequePrivateKey(t.Context(), &row)
		require.NoError(t, err)
		wif, err := btcutil.DecodeWIF(key)
		require.NoError(t, err)
		address, err := btcutil.NewAddressWitnessPubKeyHash(btcutil.Hash160(wif.SerializePubKey()), engine.chainParams)
		require.NoError(t, err)
		require.Equal(t, row.Address, address.EncodeAddress())
	}
}

func TestBackupKeepsChequeDomains(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	source := testChequeEngine(t, chain)
	var last *cheques.Cheque
	for range 26 {
		var err error
		last, err = source.CreateCheque(t.Context(), chequeWalletID, 1000)
		require.NoError(t, err)
		require.NoError(t, cheques.Delete(t.Context(), source.db, chequeWalletID, last.ID))
	}
	chain.funded[last.Address] = testUTXOs()
	dir := t.TempDir()
	walletData := []byte(fmt.Sprintf(`{"wallets":[{"id":%q,"master":{"seed_hex":%q},"l1":{}}]}`, chequeWalletID, chequeSeedHex))
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))
	data, name, err := NewBackupEngine(source.db, dir, source.network).CreateBackup(t.Context())
	require.NoError(t, err)
	restored := testChequeEngine(t, chain)
	backup := NewBackupEngine(restored.db, t.TempDir(), restored.network)
	require.NoError(t, backup.RestoreBackup(t.Context(), data, name))
	restored.recoverChequesOnUnlock(t.Context())
	rows, err := cheques.List(t.Context(), restored.db, chequeWalletID)
	require.NoError(t, err)
	require.Len(t, rows, 1)
	require.Equal(t, last.Address, rows[0].Address)
	require.Equal(t, last.KeyDomain, rows[0].KeyDomain)
	current, err := restored.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.Equal(t, uint32(26), current.DerivationIndex)
	require.NotEqual(t, chequeKeyBytes(t, source, last), chequeKeyBytes(t, restored, current))
	data, name, err = backup.CreateBackup(t.Context())
	require.NoError(t, err)
	target := testChequeEngine(t, chain)
	require.NoError(t, NewBackupEngine(target.db, t.TempDir(), target.network).RestoreBackup(t.Context(), data, name))
	got, err := cheques.GetByAddress(t.Context(), target.db, chequeWalletID, current.Address)
	require.NoError(t, err)
	require.Equal(t, chequeKeyBytes(t, restored, current), chequeKeyBytes(t, target, got))
	_, err = restored.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.NoError(t, backup.RestoreBackup(t.Context(), data, name))
	next, err := cheques.GetNextDomainIndex(t.Context(), restored.db, current.KeyDomain)
	require.NoError(t, err)
	require.Equal(t, uint32(28), next)
}

func TestChequeKeysKeepTheOriginalCatalog(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	engine.network = "ecash/first"
	engine.chainParams = &chaincfg.MainNetParams
	first, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	key := chequeKeyBytes(t, engine, first)
	engine.network = "ecash/second"
	second, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.Zero(t, second.DerivationIndex)
	require.NotEqual(t, first.KeyDomain, second.KeyDomain)
	require.NotEqual(t, key, chequeKeyBytes(t, engine, second))
	require.Equal(t, key, chequeKeyBytes(t, engine, first))
}

func TestChequeKeysDoNotReuseDiscardedLegacyKey(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	legacy := &cheques.Cheque{WalletID: chequeWalletID}
	oldKey := chequeKeyBytes(t, engine, legacy)
	current, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.Zero(t, current.DerivationIndex)
	require.NotEqual(t, oldKey, chequeKeyBytes(t, engine, current))
}

func TestChequeKeyVersionOneVector(t *testing.T) {
	engine := testChequeEngine(t, &fakeChain{})
	cheque, err := engine.CreateCheque(t.Context(), chequeWalletID, 1000)
	require.NoError(t, err)
	require.Equal(t, "tb1qypcpz0hkvat7tmgdq0555acenzj0pmxyx54fah", cheque.Address)
	require.Equal(t, "8593b2ec7c11d4e91282f765f8da0027713e414c4ee6ff76891af3be66c5ae55", cheque.KeyDomain)
}
