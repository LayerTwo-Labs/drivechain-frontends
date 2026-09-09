package bitnames

import (
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/lightwallet"
)

// deriveAddress answers the address the bitnames wallet holds at one index.
//
// The node derives m/0'/index over BIP32-Ed25519, and the index is not
// hardened. The first step names the tx signing branch, and the encryption and
// the message signing branches sit beside it.
func deriveAddress(seed []byte, index uint32) (lightwallet.Address, error) {
	if index >= lightwallet.Hardened {
		return lightwallet.Address{}, fmt.Errorf("index %d is past the soft range", index)
	}
	master, err := lightwallet.Bip32Ed25519Master(seed)
	if err != nil {
		return lightwallet.Address{}, err
	}
	child, err := master.Derive([]uint32{lightwallet.Hardened, index})
	if err != nil {
		return lightwallet.Address{}, err
	}
	public, err := child.PublicKey()
	if err != nil {
		return lightwallet.Address{}, err
	}
	return lightwallet.AddressForKey(public), nil
}
