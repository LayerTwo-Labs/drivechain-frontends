package api_wallet

import (
	"context"
	"encoding/json"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

// TestDeriveAndCheckAddressesIntegration tests the actual implementation
// Run with: go test -v -run TestDeriveAndCheckAddressesIntegration
func TestDeriveAndCheckAddressesIntegration(t *testing.T) {
	ctrl := gomock.NewController(t)
	defer ctrl.Finish()

	ctx := context.Background()

	// Create temp directory for wallet.json
	tempDir := t.TempDir()
	walletFile := filepath.Join(tempDir, "wallet.json")

	// Your actual wallet data from wallet.json
	walletData := map[string]interface{}{
		"version":        1,
		"activeWalletId": "80CEBA2163224572BDEADD2D2181C51B",
		"wallets": []map[string]interface{}{
			{
				"version": 1,
				"master": map[string]interface{}{
					"seed_hex": "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364",
				},
				"l1": map[string]interface{}{
					"mnemonic": "hover drama license spread finish tray permit glad help minimum rough stove",
				},
				"id":          "80CEBA2163224572BDEADD2D2181C51B",
				"name":        "asd",
				"wallet_type": "bitcoinCore",
			},
		},
	}

	// Write wallet.json
	data, err := json.Marshal(walletData)
	require.NoError(t, err)
	err = os.WriteFile(walletFile, data, 0644)
	require.NoError(t, err)

	// Create mock bitcoind
	mockBitcoind := mocks.NewMockBitcoinServiceClient(ctrl)

	// Create wallet manager with temp directory and bitcoind connector
	walletManager := engines.NewWalletManager(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return mockBitcoind, nil
		},
		nil, // enforcer connector not needed
		tempDir,
		&chaincfg.SigNetParams,
	)

	// Mock GetBitcoinCoreWalletName to return expected wallet name
	// The actual implementation uses first 8 chars of wallet ID
	expectedCoreWalletName := "wallet_80CEBA21"

	// Mock all Bitcoin Core wallet management calls
	mockBitcoind.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{
				Wallets: []string{expectedCoreWalletName},
			},
		}, nil).
		AnyTimes()

	mockBitcoind.EXPECT().
		CreateWallet(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.CreateWalletResponse]{
			Msg: &corepb.CreateWalletResponse{
				Name: expectedCoreWalletName,
			},
		}, nil).
		AnyTimes()

	mockBitcoind.EXPECT().
		ImportDescriptors(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ImportDescriptorsResponse]{
			Msg: &corepb.ImportDescriptorsResponse{},
		}, nil).
		AnyTimes()

	// Create server with real wallet manager
	bitcoindService := service.New("test-bitcoind", func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
		return mockBitcoind, nil
	})

	server := &Server{
		database:      nil, // Not needed for address derivation
		bitcoind:      bitcoindService,
		walletManager: walletManager,
		walletDir:     tempDir,
	}

	t.Run("derive addresses with no transactions - all unused", func(t *testing.T) {
		// Mock ListTransactions to return empty (no addresses used)
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			DoAndReturn(func(ctx context.Context, req *connect.Request[corepb.ListTransactionsRequest]) (*connect.Response[corepb.ListTransactionsResponse], error) {
				// Verify we're querying the correct wallet
				require.Equal(t, expectedCoreWalletName, req.Msg.Wallet)

				return &connect.Response[corepb.ListTransactionsResponse]{
					Msg: &corepb.ListTransactionsResponse{
						Transactions: []*corepb.GetTransactionResponse{},
					},
				}, nil
			})

		// Call the ACTUAL implementation
		firstUnused, derivedAddresses, err := server.deriveAndCheckAddresses(ctx, "80CEBA2163224572BDEADD2D2181C51B")

		require.NoError(t, err)
		require.NotEmpty(t, firstUnused, "Should return first unused address")
		require.Len(t, derivedAddresses, 100, "Should derive 100 addresses")

		// First address should be the unused one
		require.Equal(t, derivedAddresses[0].Address, firstUnused)
		require.Equal(t, uint32(0), derivedAddresses[0].Index)
		require.False(t, derivedAddresses[0].Used)

		// All should be unused
		for _, addr := range derivedAddresses {
			require.False(t, addr.Used, "All addresses should be unused")
		}

		t.Logf("\n=== Test Results ===")
		t.Logf("First unused address (index 0): %s", firstUnused)
		t.Logf("Total addresses derived: %d", len(derivedAddresses))
		t.Logf("\nFirst 5 addresses:")
		for i := 0; i < 5 && i < len(derivedAddresses); i++ {
			t.Logf("  [%d] %s (used: %v)", derivedAddresses[i].Index, derivedAddresses[i].Address, derivedAddresses[i].Used)
		}
	})

	t.Run("first 3 addresses used - returns index 3", func(t *testing.T) {
		// First, we need to know what addresses will be derived
		// So we call once to get them
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListTransactionsResponse]{
				Msg: &corepb.ListTransactionsResponse{
					Transactions: []*corepb.GetTransactionResponse{},
				},
			}, nil)

		_, allAddresses, err := server.deriveAndCheckAddresses(ctx, "80CEBA2163224572BDEADD2D2181C51B")
		require.NoError(t, err)

		// Now mock with first 3 addresses marked as used
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListTransactionsResponse]{
				Msg: &corepb.ListTransactionsResponse{
					Transactions: []*corepb.GetTransactionResponse{
						{
							Details: []*corepb.GetTransactionResponse_Details{
								{Address: allAddresses[0].Address, Amount: 0.1},
							},
						},
						{
							Details: []*corepb.GetTransactionResponse_Details{
								{Address: allAddresses[1].Address, Amount: 0.2},
							},
						},
						{
							Details: []*corepb.GetTransactionResponse_Details{
								{Address: allAddresses[2].Address, Amount: 0.3},
							},
						},
					},
				},
			}, nil)

		// Call again with mocked transactions
		firstUnused, derivedAddresses, err := server.deriveAndCheckAddresses(ctx, "80CEBA2163224572BDEADD2D2181C51B")

		require.NoError(t, err)
		require.NotEmpty(t, firstUnused)

		// Should return the 4th address (index 3)
		require.Equal(t, allAddresses[3].Address, firstUnused)
		require.Equal(t, derivedAddresses[3].Address, firstUnused)

		// Verify usage flags
		require.True(t, derivedAddresses[0].Used, "Address 0 should be marked used")
		require.True(t, derivedAddresses[1].Used, "Address 1 should be marked used")
		require.True(t, derivedAddresses[2].Used, "Address 2 should be marked used")
		require.False(t, derivedAddresses[3].Used, "Address 3 should be unused")

		t.Logf("\n=== Test Results ===")
		t.Logf("Addresses 0-2 marked as used")
		t.Logf("First unused address (index 3): %s", firstUnused)
		t.Logf("\nAddress usage:")
		for i := 0; i < 5 && i < len(derivedAddresses); i++ {
			t.Logf("  [%d] %s (used: %v)", derivedAddresses[i].Index, derivedAddresses[i].Address, derivedAddresses[i].Used)
		}
	})

	t.Run("address with zero balance is reused - returns next unused", func(t *testing.T) {
		// Get all addresses first
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListTransactionsResponse]{
				Msg: &corepb.ListTransactionsResponse{
					Transactions: []*corepb.GetTransactionResponse{},
				},
			}, nil)

		_, allAddresses, err := server.deriveAndCheckAddresses(ctx, "80CEBA2163224572BDEADD2D2181C51B")
		require.NoError(t, err)

		// Mock: address 0 received and spent (balance=0, but has transactions)
		// Address 1 never used
		mockBitcoind.EXPECT().
			ListTransactions(gomock.Any(), gomock.Any()).
			Return(&connect.Response[corepb.ListTransactionsResponse]{
				Msg: &corepb.ListTransactionsResponse{
					Transactions: []*corepb.GetTransactionResponse{
						{
							Details: []*corepb.GetTransactionResponse_Details{
								{Address: allAddresses[0].Address, Amount: 1.0}, // Received
							},
						},
						{
							Details: []*corepb.GetTransactionResponse_Details{
								{Address: allAddresses[0].Address, Amount: -1.0}, // Spent
							},
						},
					},
				},
			}, nil)

		firstUnused, derivedAddresses, err := server.deriveAndCheckAddresses(ctx, "80CEBA2163224572BDEADD2D2181C51B")

		require.NoError(t, err)

		// Should NOT return address 0 (even though balance is 0, it has been used)
		// Should return address 1
		require.NotEqual(t, allAddresses[0].Address, firstUnused, "Should not reuse emptied address")
		require.Equal(t, allAddresses[1].Address, firstUnused, "Should return first truly unused address")

		require.True(t, derivedAddresses[0].Used, "Address 0 should be marked used (has transactions)")
		require.False(t, derivedAddresses[1].Used, "Address 1 should be unused")

		t.Logf("\n=== Test Results ===")
		t.Logf("Address 0 has transactions (received and spent) - marked as USED")
		t.Logf("Address 1 has no transactions - returned as first unused")
		t.Logf("First unused: %s", firstUnused)
		t.Log("\nThis test proves we don't reuse emptied addresses!")
	})
}
