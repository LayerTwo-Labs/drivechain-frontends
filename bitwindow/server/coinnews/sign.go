package coinnews

import (
	"crypto/sha256"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2/schnorr"
)

// taggedHash implements BIP-340's tagged-hash construction:
//
//	TaggedHash(tag, m) = SHA256(SHA256(tag) || SHA256(tag) || m)
//
// We pre-compute SHA256(tag) for the two tags CoinNews uses so signing
// and verifying don't re-hash the constant on every call.
var (
	tagCommentHash = sha256.Sum256([]byte("CoinNews/Comment"))
	tagVoteHash    = sha256.Sum256([]byte("CoinNews/Vote"))
)

func taggedHash(tag [32]byte, msg ...[]byte) [32]byte {
	h := sha256.New()
	h.Write(tag[:])
	h.Write(tag[:])
	for _, m := range msg {
		h.Write(m)
	}
	var out [32]byte
	copy(out[:], h.Sum(nil))
	return out
}

// CommentSigHash is the 32-byte digest a Comment's signature MUST cover
// per BIP §7.
func CommentSigHash(parent ItemID, tlvBlob []byte) [32]byte {
	return taggedHash(tagCommentHash, parent[:], tlvBlob)
}

// VoteSigHash is the digest a Vote's signature MUST cover per BIP §8.
// Includes the type tag byte so an upvote and a downvote signed against
// the same target produce different digests — protects against trivial
// up-to-down replay.
func VoteSigHash(typetag TypeTag, target ItemID) [32]byte {
	return taggedHash(tagVoteHash, []byte{byte(typetag)}, target[:])
}

// VerifyCommentSig is true iff `sig` is a valid BIP-340 Schnorr
// signature by `authorXPK` over CommentSigHash(parent, tlvBlob).
func VerifyCommentSig(authorXPK [XOnlyPubKeyLen]byte, parent ItemID, tlvBlob []byte, sig [SchnorrSigLen]byte) bool {
	return verifySchnorr(authorXPK, CommentSigHash(parent, tlvBlob), sig)
}

// VerifyVoteSig is true iff `sig` is a valid BIP-340 Schnorr signature
// by `authorXPK` over VoteSigHash(typetag, target).
func VerifyVoteSig(authorXPK [XOnlyPubKeyLen]byte, typetag TypeTag, target ItemID, sig [SchnorrSigLen]byte) bool {
	return verifySchnorr(authorXPK, VoteSigHash(typetag, target), sig)
}

func verifySchnorr(xpk [XOnlyPubKeyLen]byte, digest [32]byte, sig [SchnorrSigLen]byte) bool {
	pk, err := schnorr.ParsePubKey(xpk[:])
	if err != nil {
		return false
	}
	parsedSig, err := schnorr.ParseSignature(sig[:])
	if err != nil {
		return false
	}
	return parsedSig.Verify(digest[:], pk)
}

// ErrBadSignature is returned by decoders when a signature fails
// verification. Tests assert against this so behaviour stays observable
// without leaking schnorr internals.
var ErrBadSignature = fmt.Errorf("coinnews: signature verification failed")
