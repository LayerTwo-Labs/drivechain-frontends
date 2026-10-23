package api

import (
	"encoding/hex"
	"testing"

	"connectrpc.com/connect/v2"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestImportGroupRejectsBadPaths(t *testing.T) {
	for _, path := range []string{"m/48'//0'", "m/48'/0'/", "m/2147483648'"} {
		t.Run(path, func(t *testing.T) {
			h, walletID, group := newGroupImportHandler(t, path)
			resp, err := h.ImportGroupFromTxid(t.Context(), &pb.ImportGroupFromTxidRequest{WalletId: walletID, Txid: group.ID})
			require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
			require.Nil(t, resp)
		})
	}
}

func TestImportGroupFindsTheWalletKey(t *testing.T) {
	h, walletID, group := newGroupImportHandler(t, "m/48'/1'/0'/2'")
	resp, err := h.ImportGroupFromTxid(t.Context(), &pb.ImportGroupFromTxidRequest{WalletId: walletID, Txid: group.ID})
	require.NoError(t, err)
	require.Equal(t, group.ID, resp.Group.Id)
	require.Equal(t, []uint32{0}, resp.WalletKeyIndices)
}

func newGroupImportHandler(t *testing.T, path string) (*MultisigLoungeHandler, string, wallet.MultisigGroupData) {
	t.Helper()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	w, err := svc.GenerateWallet("Group", syncTestMnemonic, "", nil)
	require.NoError(t, err)
	xpub, err := wallet.DeriveAccountXpub(w.Master.SeedHex, "m/48'/1'/0'/2'", &chaincfg.SigNetParams)
	require.NoError(t, err)
	group := wallet.MultisigGroupData{
		ID: "group", Name: "Group", N: 1, M: 1,
		Keys: []wallet.MultisigGroupKey{{Xpub: xpub, DerivationPath: path}},
	}
	message, err := wallet.EncodeGroupOpReturn(group, 1719500000)
	require.NoError(t, err)
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(message)).Script()
	require.NoError(t, err)
	backend := &detailsProvider{rawTx: &wallet.RawTransaction{
		TxID: group.ID, Vout: []wallet.RawTxOut{{ScriptPubKey: wallet.ScriptPubKey{Hex: hex.EncodeToString(script)}}},
	}}
	h := NewMultisigLoungeHandler()
	h.SetService(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, backend, wallet.StaticParams(&chaincfg.SigNetParams), zerolog.Nop()))
	return h, w.ID, group
}
