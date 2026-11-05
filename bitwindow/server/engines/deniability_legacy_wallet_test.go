package engines_test

import (
	"context"
	"database/sql"
	"os"
	"path/filepath"
	"testing"
	"testing/fstest"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/deniability"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sqlitemigrate"
)

const legacyDenialTip = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"

type legacyDenialWallets struct {
	orchrpc.WalletManagerServiceClient
	active string
}

func (w *legacyDenialWallets) ListWallets(context.Context, *orchpb.ListWalletsRequest) (*orchpb.ListWalletsResponse, error) {
	return &orchpb.ListWalletsResponse{
		ActiveWalletId: w.active,
		Wallets: []*orchpb.WalletMetadata{
			{Id: "owner-wallet", WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE},
			{Id: "other-wallet", WalletType: orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE},
		},
	}, nil
}

func (w *legacyDenialWallets) CreateBitcoinCoreWallet(_ context.Context, req *orchpb.CreateBitcoinCoreWalletRequest) (*orchpb.CreateBitcoinCoreWalletResponse, error) {
	return &orchpb.CreateBitcoinCoreWalletResponse{CoreWalletName: req.WalletId}, nil
}

type legacyDenialCore struct {
	corerpc.BitcoinServiceClient
	reads []string
}

func (c *legacyDenialCore) ListUnspent(_ context.Context, req *connect.Request[corepb.ListUnspentRequest]) (*connect.Response[corepb.ListUnspentResponse], error) {
	c.reads = append(c.reads, req.Msg.Wallet)
	resp := &corepb.ListUnspentResponse{}
	if req.Msg.Wallet == "owner-wallet" {
		resp.Unspent = []*corepb.UnspentOutput{{Txid: legacyDenialTip, Vout: 0, Amount: 0.01, Confirmations: 6}}
	}
	return connect.NewResponse(resp), nil
}

func legacyDenialDatabase(t *testing.T) (config.Config, int64) {
	t.Helper()
	conf := config.Config{Datadir: t.TempDir()}
	db, err := sql.Open("sqlite3", filepath.Join(conf.Datadir, "bitwindow.db"))
	require.NoError(t, err)
	db.SetMaxOpenConns(1)
	t.Cleanup(func() { require.NoError(t, db.Close()) })

	files, err := os.ReadDir("../database/migrations")
	require.NoError(t, err)
	old := fstest.MapFS{}
	for _, file := range files {
		if file.Name() >= "021_" {
			continue
		}
		body, err := os.ReadFile(filepath.Join("../database/migrations", file.Name()))
		require.NoError(t, err)
		old["migrations/"+file.Name()] = &fstest.MapFile{Data: body}
	}
	_, err = sqlitemigrate.Run(t.Context(), db, old, "migrations")
	require.NoError(t, err)
	result, err := db.ExecContext(t.Context(), `
		INSERT INTO denials (initial_txid, initial_vout, delay_duration, num_hops, created_at)
		VALUES (?, 0, ?, 3, ?)
	`, legacyDenialTip, int64(time.Hour), time.Now())
	require.NoError(t, err)
	id, err := result.LastInsertId()
	require.NoError(t, err)
	require.NoError(t, db.Close())
	return conf, id
}

func TestLegacyDenialSurvivesWalletChange(t *testing.T) {
	for _, active := range []string{"owner-wallet", "other-wallet"} {
		t.Run(active, func(t *testing.T) {
			conf, id := legacyDenialDatabase(t)
			db, err := database.New(t.Context(), conf)
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, db.Close()) })
			plan, err := deniability.Get(t.Context(), db, id)
			require.NoError(t, err)
			require.Nil(t, plan.WalletID)
			require.Nil(t, plan.CancelledAt)
			require.NotNil(t, plan.NextExecution)

			wallets := &legacyDenialWallets{active: "owner-wallet"}
			core := &legacyDenialCore{}
			client := func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return core, ctx.Err() }
			makeEngine := func(store *sql.DB) *engines.DeniabilityEngine {
				wallet := engines.NewWalletEngine(client, wallets, &chaincfg.SigNetParams, nil)
				return engines.NewDeniability(service.New("review-core", client), store, wallet)
			}
			engine := makeEngine(db)
			_, plans, err := engine.CleanupDenials(t.Context())
			require.NoError(t, err)
			require.Len(t, plans, 1)

			wallets.active = active
			_, _, err = engine.CleanupDenials(t.Context())
			require.NoError(t, err)
			require.NoError(t, db.Close())
			db, err = database.New(t.Context(), conf)
			require.NoError(t, err)
			wallets.active = "owner-wallet"
			_, plans, err = makeEngine(db).CleanupDenials(t.Context())
			require.NoError(t, err)
			plan, err = deniability.Get(t.Context(), db, id)
			require.NoError(t, err)
			coins, err := core.ListUnspent(t.Context(), connect.NewRequest(&corepb.ListUnspentRequest{Wallet: "owner-wallet"}))
			require.NoError(t, err)
			require.Len(t, coins.Msg.Unspent, 1)
			require.Equal(t, legacyDenialTip, coins.Msg.Unspent[0].Txid)
			require.Nil(t, plan.CancelledAt, "the owner wallet still holds the denial tip")
			require.NotNil(t, plan.WalletID)
			require.Equal(t, "owner-wallet", *plan.WalletID)
			require.Len(t, plans, 1)
		})
	}
}
