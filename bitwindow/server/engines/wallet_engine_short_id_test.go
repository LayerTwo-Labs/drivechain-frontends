package engines

import (
	"context"
	"errors"
	"strings"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// A wallet id too short to name a Core wallet must be skipped rather than
// panic, and must not stop the well-formed wallets from syncing.
func TestEnsureBitcoinCoreWalletsSkipsShortWalletID(t *testing.T) {
	ctrl := gomock.NewController(t)
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{Wallets: []string{}},
		}, nil).
		AnyTimes()

	var created []string
	mockBitcoind.EXPECT().
		CreateWallet(gomock.Any(), gomock.Any()).
		DoAndReturn(func(_ context.Context, req *connect.Request[corepb.CreateWalletRequest]) (*connect.Response[corepb.CreateWalletResponse], error) {
			created = append(created, req.Msg.Name)
			return nil, errors.New("bitcoind unavailable")
		}).
		AnyTimes()

	e := NewWalletEngine(func(context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	}, t.TempDir(), &chaincfg.MainNetParams)

	short := WalletInfo{ID: "abc", WalletType: WalletTypeBitcoinCore}
	good := WalletInfo{ID: "deadbeefcafebabe", WalletType: WalletTypeBitcoinCore}
	good.Master.SeedHex = strings.Repeat("ab", 32)

	require.NoError(t, e.ensureBitcoinCoreWallets(testCtx(), []WalletInfo{short, good}))
	require.Equal(t, []string{"wallet_deadbeef"}, created, "the short id must be skipped and the well-formed wallet still ensured")
}
