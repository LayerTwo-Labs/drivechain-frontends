package bip47

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"golang.org/x/crypto/ripemd160" //nolint:staticcheck // Bitcoin protocol requires RIPEMD160
)

// ecdhX returns the raw 32-byte big-endian X coordinate of priv·pub on
// secp256k1. Unlike btcec.GenerateSharedSecret, this does NOT hash the result.
func ecdhX(priv *btcec.PrivateKey, pub *btcec.PublicKey) ([32]byte, error) {
	var out [32]byte
	if priv == nil || pub == nil {
		return out, errors.New("nil priv or pub")
	}
	var pj btcec.JacobianPoint
	pub.AsJacobian(&pj)
	var res btcec.JacobianPoint
	btcec.ScalarMultNonConst(&priv.Key, &pj, &res)
	res.ToAffine()
	res.X.PutBytesUnchecked(out[:])
	return out, nil
}

// tweakPubKey returns B + s·G as a normalized public key. Returns an error if
// s is zero, ≥ n, or the resulting point is the identity.
func tweakPubKey(b *btcec.PublicKey, s [32]byte) (*btcec.PublicKey, error) {
	var scalar btcec.ModNScalar
	if overflow := scalar.SetBytes(&s); overflow != 0 {
		return nil, errors.New("scalar overflow (s >= n)")
	}
	if scalar.IsZero() {
		return nil, errors.New("scalar is zero")
	}
	var sG btcec.JacobianPoint
	btcec.ScalarBaseMultNonConst(&scalar, &sG)
	var bj btcec.JacobianPoint
	b.AsJacobian(&bj)
	var sum btcec.JacobianPoint
	btcec.AddNonConst(&bj, &sG, &sum)
	if sum.X.IsZero() && sum.Y.IsZero() {
		return nil, errors.New("tweak resulted in point at infinity")
	}
	sum.ToAffine()
	return btcec.NewPublicKey(&sum.X, &sum.Y), nil
}

func hash160(data []byte) []byte {
	sum := sha256.Sum256(data)
	r := ripemd160.New()
	r.Write(sum[:])
	return r.Sum(nil)
}

func p2pkhAddress(pub *btcec.PublicKey, net *chaincfg.Params) (btcutil.Address, error) {
	pkHash := hash160(pub.SerializeCompressed())
	return btcutil.NewAddressPubKeyHash(pkHash, net)
}

func p2wpkhAddress(pub *btcec.PublicKey, net *chaincfg.Params) (btcutil.Address, error) {
	pkHash := hash160(pub.SerializeCompressed())
	return btcutil.NewAddressWitnessPubKeyHash(pkHash, net)
}

func hexDecode(s string) ([]byte, error) { return hex.DecodeString(s) }
func hexEncode(b []byte) string           { return hex.EncodeToString(b) }
