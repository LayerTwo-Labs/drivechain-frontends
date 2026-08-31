package thunderwallet

import (
	"crypto/ed25519"
	"errors"
	"fmt"
)

// ErrNoKeyForAddress says the wallet holds no key for a coin it tries to spend.
var ErrNoKeyForAddress = errors.New("no key for address")

// Keyring answers with the key that owns one address.
type Keyring interface {
	// SigningKey returns the key for an address, or ErrNoKeyForAddress.
	SigningKey(address Address) (ed25519.PrivateKey, error)
}

// AuthorizedTransaction is a transaction with one signature per input, in
// input order. The node checks that count, and rejects any other.
type AuthorizedTransaction struct {
	Transaction    Transaction
	Authorizations []Authorization
}

// Sign authorizes every input of a transaction.
//
// Each signature covers the whole canonical encoding, not one input, so the
// same bytes get signed once per input by whichever key owns that coin.
// spentAddresses names the owner of each input, in input order; a caller reads
// them from the index or from the node.
func Sign(
	tx Transaction, spentAddresses []Address, keys Keyring,
) (AuthorizedTransaction, error) {
	if len(spentAddresses) != len(tx.Inputs) {
		return AuthorizedTransaction{}, fmt.Errorf(
			"transaction spends %d inputs but names %d owners",
			len(tx.Inputs), len(spentAddresses))
	}

	message, err := EncodeTransaction(tx)
	if err != nil {
		return AuthorizedTransaction{}, err
	}

	authorizations := make([]Authorization, 0, len(tx.Inputs))
	for i, address := range spentAddresses {
		key, err := keys.SigningKey(address)
		if err != nil {
			return AuthorizedTransaction{}, fmt.Errorf(
				"input %d pays from %s: %w", i, address, err)
		}
		public, ok := key.Public().(ed25519.PublicKey)
		if !ok {
			return AuthorizedTransaction{}, fmt.Errorf(
				"input %d: the key for %s is not ed25519", i, address)
		}
		// The node rejects a signature whose key hashes to another address, so
		// catch it here where the message names the wallet, not the wire.
		if got := AddressForKey(public); got != address {
			return AuthorizedTransaction{}, fmt.Errorf(
				"input %d: the key for %s derives %s instead", i, address, got)
		}
		authorizations = append(authorizations, Authorization{
			VerifyingKey: public,
			Signature:    ed25519.Sign(key, message),
		})
	}

	return AuthorizedTransaction{Transaction: tx, Authorizations: authorizations}, nil
}

// Verify checks a signed transaction the way the node does, so a caller finds
// a fault before it reaches the network.
func Verify(tx AuthorizedTransaction) error {
	if len(tx.Authorizations) != len(tx.Transaction.Inputs) {
		return fmt.Errorf(
			"transaction has %d signatures for %d inputs",
			len(tx.Authorizations), len(tx.Transaction.Inputs))
	}
	message, err := EncodeTransaction(tx.Transaction)
	if err != nil {
		return err
	}
	for i, auth := range tx.Authorizations {
		if len(auth.VerifyingKey) != ed25519.PublicKeySize {
			return fmt.Errorf("signature %d carries a %d byte key, want %d",
				i, len(auth.VerifyingKey), ed25519.PublicKeySize)
		}
		if !ed25519.Verify(auth.VerifyingKey, message, auth.Signature) {
			return fmt.Errorf("signature %d does not verify", i)
		}
	}
	return nil
}

// MemoryKeyring holds keys by the address each one owns, and keeps the order
// they arrived in. A caller picks a receive address by that order, so it must
// stay the derivation order rather than a map order.
type MemoryKeyring struct {
	keys  map[Address]ed25519.PrivateKey
	order []Address
}

// NewMemoryKeyring indexes each key by the address it derives.
func NewMemoryKeyring(keys ...ed25519.PrivateKey) *MemoryKeyring {
	ring := &MemoryKeyring{keys: make(map[Address]ed25519.PrivateKey, len(keys))}
	for _, key := range keys {
		ring.Add(key)
	}
	return ring
}

// Add indexes one key. It returns the address that key owns.
func (r *MemoryKeyring) Add(key ed25519.PrivateKey) Address {
	address := AddressForKey(key.Public().(ed25519.PublicKey))
	if _, seen := r.keys[address]; !seen {
		r.order = append(r.order, address)
	}
	r.keys[address] = key
	return address
}

// SigningKey answers with the key for an address.
func (r *MemoryKeyring) SigningKey(address Address) (ed25519.PrivateKey, error) {
	key, ok := r.keys[address]
	if !ok {
		return nil, fmt.Errorf("%s: %w", address, ErrNoKeyForAddress)
	}
	return key, nil
}

// Addresses lists every address the keyring owns, in the order they arrived.
func (r *MemoryKeyring) Addresses() []Address {
	return append([]Address(nil), r.order...)
}

var _ Keyring = (*MemoryKeyring)(nil)
