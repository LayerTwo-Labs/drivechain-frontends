package coinshift

import (
	"crypto/ed25519"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

// deriveAddress answers the address the coinshift wallet holds at one index.
// The node derives m/1'/0'/0'/index' over SLIP-0010 ed25519.
func deriveAddress(seed []byte, index uint32) (lightwallet.Address, error) {
	key, err := lightwallet.Slip10Key(seed, []uint32{
		lightwallet.Hardened + 1,
		lightwallet.Hardened,
		lightwallet.Hardened,
		lightwallet.Hardened + index,
	})
	if err != nil {
		return lightwallet.Address{}, err
	}
	return lightwallet.AddressForKey(key.Public().(ed25519.PublicKey)), nil
}
