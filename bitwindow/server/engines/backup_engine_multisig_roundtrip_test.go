package engines

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/stretchr/testify/require"
)

// Exporting and re-importing multisig.json must preserve every field.
func TestExportMultisigJSON_RoundTrip(t *testing.T) {
	ctx := context.Background()
	db := database.Test(t)
	store := multisig.NewStore(db)
	e := &BackupEngine{db: db, walletDir: t.TempDir(), multisigStore: store}

	wantGroup := multisig.Group{
		ID:                "group-1",
		Name:              "Savings",
		N:                 2,
		M:                 3,
		Created:           1751400000,
		Txid:              "abc123",
		Descriptor:        "wsh(sortedmulti(2,A,B,C))",
		DescriptorReceive: "wsh(sortedmulti(2,A/0/*,B/0/*,C/0/*))",
		DescriptorChange:  "wsh(sortedmulti(2,A/1/*,B/1/*,C/1/*))",
		WatchWalletName:   "watch_group_1",
		Balance:           2.5,
		Utxos:             4,
		NextReceiveIndex:  7,
		NextChangeIndex:   3,
	}
	require.NoError(t, store.SaveGroup(ctx, wantGroup))

	wantKeys := []multisig.Key{
		{GroupID: "group-1", Owner: "me", Xpub: "tpubA", DerivationPath: "m/48'/1'/0'/2'", Fingerprint: "aabbccdd", OriginPath: "48h/1h/0h/2h", IsWallet: true, SortOrder: 0},
		{GroupID: "group-1", Owner: "alice", Xpub: "tpubB", DerivationPath: "m/48'/1'/1'/2'", Fingerprint: "11223344", OriginPath: "48h/1h/1h/2h", IsWallet: false, SortOrder: 1},
	}
	require.NoError(t, store.ReplaceKeysForGroup(ctx, "group-1", wantKeys))

	wantAddrs := []multisig.Address{
		{GroupID: "group-1", AddrType: "receive", Index: 0, Addr: "bc1qreceive0", Used: true},
		{GroupID: "group-1", AddrType: "receive", Index: 1, Addr: "bc1qreceive1", Used: false},
		{GroupID: "group-1", AddrType: "change", Index: 0, Addr: "bc1qchange0", Used: true},
	}
	require.NoError(t, store.ReplaceAddresses(ctx, "group-1", wantAddrs))
	require.NoError(t, store.ReplaceGroupTransactionIDs(ctx, "group-1", []string{"tx-a", "tx-b"}))

	wantSolo := multisig.SoloKey{
		Xpub: "tpubSolo", DerivationPath: "m/84'/1'/0'", Fingerprint: "deadbeef", OriginPath: "84h/1h/0h", Owner: "me",
	}
	require.NoError(t, store.AddSoloKey(ctx, wantSolo))

	multisigJSON, err := e.exportMultisigJSON(ctx)
	require.NoError(t, err)
	require.NotNil(t, multisigJSON)

	// Wipe the group, then restore it from the exported file.
	_, err = db.ExecContext(ctx, `DELETE FROM multisig_groups WHERE id = ?`, wantGroup.ID)
	require.NoError(t, err)
	_, err = db.ExecContext(ctx, `DELETE FROM multisig_solo_keys`)
	require.NoError(t, err)
	require.NoError(t, store.ImportFromJSON(ctx, multisigJSON))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	got := groups[0]

	require.Equal(t, wantGroup.Name, got.Name)
	require.Equal(t, wantGroup.Descriptor, got.Descriptor)
	require.Equal(t, wantGroup.DescriptorReceive, got.DescriptorReceive)
	require.Equal(t, wantGroup.DescriptorChange, got.DescriptorChange)
	require.Equal(t, wantGroup.WatchWalletName, got.WatchWalletName, "watch wallet name must survive")
	require.Equal(t, wantGroup.NextReceiveIndex, got.NextReceiveIndex, "next receive index must survive, else addresses get reused")
	require.Equal(t, wantGroup.NextChangeIndex, got.NextChangeIndex, "next change index must survive")

	gotKeys, err := store.ListKeysForGroup(ctx, "group-1")
	require.NoError(t, err)
	require.Len(t, gotKeys, 2)
	require.Equal(t, "m/48'/1'/0'/2'", gotKeys[0].DerivationPath, "derivation path must survive")
	require.Equal(t, "48h/1h/0h/2h", gotKeys[0].OriginPath, "origin path must survive")
	require.True(t, gotKeys[0].IsWallet, "is_wallet must survive, else the wallet cannot sign")
	require.False(t, gotKeys[1].IsWallet)
	require.Equal(t, "tpubB", gotKeys[1].Xpub)

	gotAddrs, err := store.ListAddresses(ctx, "group-1")
	require.NoError(t, err)
	require.Len(t, gotAddrs, 3, "all addresses must survive")

	byAddr := map[string]multisig.Address{}
	for _, a := range gotAddrs {
		byAddr[a.Addr] = a
	}
	require.Equal(t, "receive", byAddr["bc1qreceive0"].AddrType)
	require.True(t, byAddr["bc1qreceive0"].Used)
	require.Equal(t, 1, byAddr["bc1qreceive1"].Index)
	require.Equal(t, "change", byAddr["bc1qchange0"].AddrType)

	gotTxIDs, err := store.ListGroupTransactionIDs(ctx, "group-1")
	require.NoError(t, err)
	require.ElementsMatch(t, []string{"tx-a", "tx-b"}, gotTxIDs, "group transaction links must survive")

	gotSolo, err := store.ListSoloKeys(ctx)
	require.NoError(t, err)
	require.Len(t, gotSolo, 1)
	require.Equal(t, wantSolo.DerivationPath, gotSolo[0].DerivationPath, "solo key path must survive")
	require.Equal(t, wantSolo.OriginPath, gotSolo[0].OriginPath, "solo key origin path must survive")
}
