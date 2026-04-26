package bip47

import (
	"crypto/hmac"
	"crypto/sha512"
	"encoding/binary"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/wire"
)

// blindingMask computes the 64-byte HMAC-SHA512 mask used to blind a sender's
// payment code in a notification transaction.
//
// secretX = (a · B₀).x  where a is the designated input private key and B₀ is
// the recipient's notification pubkey. outpoint encodes txid_le(32) || vout_le(4).
//
// Per spec and Samourai/Stratis/Sparrow reference implementations: the HMAC
// uses key=outpoint, data=secretX. The BIP body wording is contradictory; the
// test vectors only line up with this ordering.
func blindingMask(secretX [32]byte, outpoint wire.OutPoint) [64]byte {
	o := serializeOutpoint(outpoint)
	mac := hmac.New(sha512.New, o[:])
	mac.Write(secretX[:])
	var out [64]byte
	copy(out[:], mac.Sum(nil))
	return out
}

func serializeOutpoint(op wire.OutPoint) [36]byte {
	var out [36]byte
	copy(out[0:32], op.Hash[:])
	binary.LittleEndian.PutUint32(out[32:36], op.Index)
	return out
}

// applyBlinding XORs bytes 3..67 of the 80-byte payment code with the 64-byte
// mask. Bytes 0..2 (version, features, sign) and 67..79 (reserved) are left
// alone.
func applyBlinding(code [PaymentCodeLength]byte, mask [64]byte) [PaymentCodeLength]byte {
	out := code
	for i := 0; i < 32; i++ {
		out[3+i] ^= mask[i]
	}
	for i := 0; i < 32; i++ {
		out[35+i] ^= mask[32+i]
	}
	return out
}

// BuildBlindedPayload returns the 80-byte blinded payment code that goes into
// the OP_RETURN of a notification transaction, given the sender's own payment
// code, the designated input's private key, the recipient's payment code, and
// the designated input's outpoint (referenced previous output).
//
// The ECDH partner is the recipient's notification pubkey B₀ = child 0 of the
// recipient's payment-code xpub, NOT the payment code's bare account pubkey.
func BuildBlindedPayload(senderCode [PaymentCodeLength]byte, designatedPriv *btcec.PrivateKey, recipient *PaymentCode, outpoint wire.OutPoint) ([PaymentCodeLength]byte, error) {
	var zero [PaymentCodeLength]byte
	if designatedPriv == nil {
		return zero, fmt.Errorf("nil designated input private key")
	}
	if recipient == nil {
		return zero, fmt.Errorf("nil recipient payment code")
	}
	b0, err := recipient.NotificationPubKey()
	if err != nil {
		return zero, fmt.Errorf("recipient B₀: %w", err)
	}
	x, err := ecdhX(designatedPriv, b0)
	if err != nil {
		return zero, fmt.Errorf("ecdh: %w", err)
	}
	mask := blindingMask(x, outpoint)
	return applyBlinding(senderCode, mask), nil
}
