package orchestrator

import "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"

// WalletSidechainSlots lists every configured sidechain slot, so wallet
// generation derives a starter for each one up front. Without this, a starter
// only appears after its sidechain launches, and the Starters tab shows blanks.
func WalletSidechainSlots() []wallet.SidechainSlot {
	var slots []wallet.SidechainSlot
	for _, c := range AllSidechains() {
		name := c.DisplayName
		if name == "" {
			name = c.Name
		}
		slots = append(slots, wallet.SidechainSlot{Slot: c.Slot, Name: name})
	}
	return slots
}
