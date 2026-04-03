package testharness

import (
	"context"
	"fmt"
	"testing"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// Mine mines blocks to the node's own wallet address.
// Requires a wallet with a Core wallet already ensured.
func (n *Node) Mine(ctx context.Context, t *testing.T, blocks int) error {
	t.Helper()

	// Get a new address from the active wallet.
	resp, err := n.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		return fmt.Errorf("get new address for mining: %w", err)
	}
	return n.MineToAddress(ctx, blocks, resp.Msg.Address)
}

// MineToAddress mines blocks to a specific address.
func (n *Node) MineToAddress(ctx context.Context, blocks int, addr string) error {
	_, err := n.CoreRPC.GenerateToAddress(ctx, blocks, addr)
	return err
}

// FundWallet sets up the node with a funded bitcoinCore wallet.
// It generates an enforcer wallet (first), then a bitcoinCore wallet (second),
// ensures Core wallets, mines 101 blocks to mature coinbase, and returns
// the funded address.
func (n *Node) FundWallet(t *testing.T) string {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	// Check if wallets already exist.
	status, err := n.WalletClient.GetWalletStatus(ctx, connect.NewRequest(&pb.GetWalletStatusRequest{}))
	if err != nil {
		t.Fatalf("testharness[%s]: get wallet status: %v", n.Name, err)
	}

	if !status.Msg.HasWallet {
		// First wallet = enforcer type (required as slot 0).
		_, err := n.WalletClient.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
			Name: n.Name + "-enforcer",
		}))
		if err != nil {
			t.Fatalf("testharness[%s]: generate enforcer wallet: %v", n.Name, err)
		}
	}

	// Second wallet = bitcoinCore type (this one gets a Core wallet).
	genResp, err := n.WalletClient.GenerateWallet(ctx, connect.NewRequest(&pb.GenerateWalletRequest{
		Name: n.Name + "-core",
	}))
	if err != nil {
		t.Fatalf("testharness[%s]: generate core wallet: %v", n.Name, err)
	}
	t.Logf("testharness[%s]: generated bitcoinCore wallet %s", n.Name, genResp.Msg.WalletId)

	// Ensure Core wallets synced.
	_, err = n.WalletClient.EnsureCoreWallets(ctx, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
	if err != nil {
		t.Fatalf("testharness[%s]: ensure core wallets: %v", n.Name, err)
	}

	// Get a new address.
	addrResp, err := n.WalletClient.GetNewAddress(ctx, connect.NewRequest(&pb.GetNewAddressRequest{}))
	if err != nil {
		t.Fatalf("testharness[%s]: get new address: %v", n.Name, err)
	}
	addr := addrResp.Msg.Address
	t.Logf("testharness[%s]: mining 101 blocks to %s", n.Name, addr)

	// Mine 101 blocks (coinbase maturity).
	if err := n.MineToAddress(ctx, 101, addr); err != nil {
		t.Fatalf("testharness[%s]: mine 101 blocks: %v", n.Name, err)
	}

	return addr
}

// WaitForBalance polls the wallet balance until it's > 0 or times out.
// Bitcoin Core on some platforms (Windows) may take a moment to index new blocks.
func (n *Node) WaitForBalance(t *testing.T) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	for {
		select {
		case <-ctx.Done():
			t.Fatalf("testharness[%s]: balance did not become positive within 30s", n.Name)
		default:
		}
		resp, err := n.WalletClient.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
		if err == nil && resp.Msg.ConfirmedSats > 0 {
			return
		}
		time.Sleep(500 * time.Millisecond)
	}
}

// ConnectTo adds a p2p connection from this node to another.
func (n *Node) ConnectTo(t *testing.T, other *Node) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	addr := fmt.Sprintf("127.0.0.1:%d", other.BitcoindP2PPort)
	if err := n.CoreRPC.AddNode(ctx, addr, "onetry"); err != nil {
		t.Fatalf("testharness[%s]: addnode to %s: %v", n.Name, other.Name, err)
	}
	n.log.Info().Str("peer", other.Name).Msg("connected p2p")
}

// WaitForSync polls until both nodes report the same block height, or times out.
func (n *Node) WaitForSync(t *testing.T, other *Node) {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	for {
		select {
		case <-ctx.Done():
			t.Fatalf("testharness: %s and %s did not sync within 30s", n.Name, other.Name)
		default:
		}

		hA, errA := n.CoreRPC.GetBlockCount(ctx)
		hB, errB := other.CoreRPC.GetBlockCount(ctx)
		if errA == nil && errB == nil && hA == hB && hA > 0 {
			n.log.Info().Int("height", hA).Msg("nodes synced")
			return
		}
		time.Sleep(250 * time.Millisecond)
	}
}
