package api

import (
	"context"
	"fmt"
	"strings"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// depositPendingSats is what this wallet paid into a sidechain treasury that
// the sidechain has not credited yet.
//
// A deposit is a mainchain transaction. The sidechain learns nothing of it
// until it connects the mainchain block that carries it, and that wait runs to
// hours. Without this the money reads as gone the whole time.
func (h *Handler) depositPendingSats(ctx context.Context, cfg orchestrator.BinaryConfig) (int64, error) {
	svc := h.orch.WalletSvc
	// A Core derived sidechain speaks Core's own wallet RPCs, so neither
	// address listing answers here.
	if svc == nil || cfg.IsBitcoinCore || cfg.ChainLayer != 2 || cfg.Slot <= 0 {
		return 0, nil
	}

	// One starter seeds the sidechain wallet for the whole install, so every
	// deposit to an address it owns lands in this balance, whichever mainchain
	// wallet paid for it.
	deposits, err := svc.SidechainDeposits(ctx, uint32(cfg.Slot), "")
	if err != nil {
		return 0, fmt.Errorf("read the deposits of %s: %w", cfg.DisplayName, err)
	}
	open := make([]wallet.SidechainDeposit, 0, len(deposits))
	for _, d := range deposits {
		if d.CreditedAt.IsZero() {
			open = append(open, d)
		}
	}
	if len(open) == 0 {
		return 0, nil
	}

	node, err := sidechainNode(cfg, config.NetworkFromString(h.orch.CurrentNetwork()))
	if err != nil {
		return 0, err
	}
	owned, err := sidechain.WalletAddresses(ctx, node)
	if err != nil {
		return 0, fmt.Errorf("read the %s wallet addresses: %w", cfg.DisplayName, err)
	}
	ourCoins, err := sidechain.OurCoins(ctx, node)
	if err != nil {
		return 0, fmt.Errorf("read the %s wallet coins: %w", cfg.DisplayName, err)
	}

	spentCoins, err := sidechain.SpentCoins(ctx, node, depositAddresses(open, owned))
	if err != nil {
		return 0, fmt.Errorf("read the %s spent wallet coins: %w", cfg.DisplayName, err)
	}

	pendingSats, credited := splitCreditedDeposits(open, owned, ourCoins, spentCoins)
	for _, txid := range credited {
		if err := svc.MarkSidechainDepositCredited(ctx, txid); err != nil {
			return 0, err
		}
	}
	return pendingSats, nil
}

// splitCreditedDeposits sums what the sidechain still owes this wallet, and
// names the deposits it now holds a coin for.
//
// A sidechain names the coin a deposit made after the mainchain outpoint that
// paid it, so one deposit answers for one coin. A deposit whose coin the wallet
// holds or spent is already in the balance, and a deposit with no coin is in no
// balance at all. So one listing puts a deposit in exactly one of the two.
func splitCreditedDeposits(
	deposits []wallet.SidechainDeposit, owned map[string]bool, ourCoins, spentCoins map[string]int64,
) (pendingSats int64, credited []string) {
	for _, d := range deposits {
		// A deposit to somebody else's address never becomes our money.
		if !owned[d.Destination] {
			continue
		}
		if holdsDepositCoin(ourCoins, d.Txid) || holdsDepositCoin(spentCoins, d.Txid) {
			credited = append(credited, d.Txid)
			continue
		}
		pendingSats += d.AmountSats
	}
	return pendingSats, credited
}

// depositAddresses names each address of ours that a deposit paid, once.
func depositAddresses(deposits []wallet.SidechainDeposit, owned map[string]bool) []string {
	seen := make(map[string]bool)
	addresses := make([]string, 0, len(deposits))
	for _, d := range deposits {
		if owned[d.Destination] && !seen[d.Destination] {
			seen[d.Destination] = true
			addresses = append(addresses, d.Destination)
		}
	}
	return addresses
}

// holdsDepositCoin is true when the wallet lists the coin this deposit made.
// A deposit outpoint is the mainchain txid and the vout it paid.
func holdsDepositCoin(ourCoins map[string]int64, txid string) bool {
	for key := range ourCoins {
		if strings.HasPrefix(key, txid+":") {
			return true
		}
	}
	return false
}
