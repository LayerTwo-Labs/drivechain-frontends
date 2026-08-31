package thunderwallet

import (
	"crypto/ed25519"
	"encoding/hex"
	"fmt"

	"github.com/mr-tron/base58"
	"lukechampine.com/blake3"
)

// AddressSize is the width of a thunder address.
const AddressSize = 20

// OutPointKind tags how an output came into being. The values are the borsh
// discriminants.
type OutPointKind uint8

const (
	KindRegular  OutPointKind = 0
	KindCoinbase OutPointKind = 1
	KindDeposit  OutPointKind = 2
)

func (k OutPointKind) String() string {
	switch k {
	case KindRegular:
		return "regular"
	case KindCoinbase:
		return "coinbase"
	case KindDeposit:
		return "deposit"
	default:
		return fmt.Sprintf("unknown(%d)", uint8(k))
	}
}

// Hash is a 32-byte digest.
type Hash [32]byte

func (h Hash) String() string { return hex.EncodeToString(h[:]) }

// Address is a 20-byte thunder address, shown as base58 with no checksum.
type Address [AddressSize]byte

func (a Address) String() string { return base58.Encode(a[:]) }

// ParseAddress reads the base58 form.
func ParseAddress(s string) (Address, error) {
	var a Address
	raw, err := base58.Decode(s)
	if err != nil {
		return a, fmt.Errorf("decode address %q: %w", s, err)
	}
	if len(raw) != AddressSize {
		return a, fmt.Errorf("address %q is %d bytes, want %d", s, len(raw), AddressSize)
	}
	copy(a[:], raw)
	return a, nil
}

// AddressForKey derives the address a public key owns: a blake3 extendable
// output over the key bytes, read 20 bytes wide.
func AddressForKey(pub ed25519.PublicKey) Address {
	var a Address
	hasher := blake3.New(32, nil)
	_, _ = hasher.Write(pub)
	_, _ = hasher.XOF().Read(a[:])
	return a
}

// OutPoint names one output.
type OutPoint struct {
	Kind   OutPointKind
	Source Hash
	Vout   uint32
}

// Input is one coin a transaction spends, with its utreexo leaf hash.
type Input struct {
	OutPoint OutPoint
	LeafHash Hash
}

// Withdrawal is an output that leaves the sidechain. It costs both its payout
// and its mainchain fee, because the enforcer pays both out of the treasury.
type Withdrawal struct {
	ValueSats   uint64
	MainFeeSats uint64
	// MainScriptPubKey is the mainchain script the payout goes to. The borsh
	// form of a bitcoin address is its script pubkey.
	MainScriptPubKey []byte
	// MainAddress is the same payout target in its text form, which is what
	// the node RPC takes.
	MainAddress string
}

// Content is what an output holds.
type Content struct {
	Value      *uint64
	Withdrawal *Withdrawal
}

// Output is one coin a transaction creates.
type Output struct {
	Address Address
	Content Content
}

// Transaction is an unsigned thunder transaction.
type Transaction struct {
	Inputs  []Input
	Outputs []Output
}

// Txid is the blake3 digest over the canonical encoding.
func (t Transaction) Txid() (Hash, error) {
	raw, err := EncodeTransaction(t)
	if err != nil {
		return Hash{}, err
	}
	return Hash(blake3.Sum256(raw)), nil
}

// Authorization is one ed25519 signature over the canonical encoding.
type Authorization struct {
	VerifyingKey ed25519.PublicKey
	Signature    []byte
}
