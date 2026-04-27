package coinnews

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// TestVarintRoundTrip pins the three compact-size width boundaries —
// the only place callers can introduce non-canonical encodings that
// would diverge between indexers.
func TestVarintRoundTrip(t *testing.T) {
	cases := []uint64{0, 1, 252, 253, 0xfffe, 0xffff, 0x10000, 0xfffffffe}
	for _, n := range cases {
		var buf bytes.Buffer
		require.NoError(t, encodeCompactSize(&buf, n))
		got, consumed, err := decodeCompactSize(buf.Bytes())
		require.NoError(t, err)
		assert.Equal(t, n, got, "value %d", n)
		assert.Equal(t, buf.Len(), consumed, "value %d (width)", n)
	}
}

// TestVarintRejectsNonCanonical guards the §4.2 determinism property:
// two indexers seeing the same OP_RETURN must reach the same decoded
// length, so non-canonical encodings (a 3-byte form expressing a value
// that fits in 1 byte) MUST be rejected.
func TestVarintRejectsNonCanonical(t *testing.T) {
	// 0xfd 0x00 0x00 — claims to be 3-byte form but value 0 fits in 1.
	_, _, err := decodeCompactSize([]byte{0xfd, 0x00, 0x00})
	assert.Error(t, err, "non-canonical 3-byte zero must fail")
	// 0xfe 0xff 0xff 0x00 0x00 — claims to be 5-byte form but value
	// 0xffff fits in the 3-byte form.
	_, _, err = decodeCompactSize([]byte{0xfe, 0xff, 0xff, 0x00, 0x00})
	assert.Error(t, err, "non-canonical 5-byte uint16 must fail")
}

func TestItemIDDeterministic(t *testing.T) {
	var txid [32]byte
	for i := range txid {
		txid[i] = byte(i)
	}
	id1 := ComputeItemID(txid, 0)
	id2 := ComputeItemID(txid, 0)
	assert.Equal(t, id1, id2)

	// Different vout = different ItemID (proves the hash includes vout).
	id3 := ComputeItemID(txid, 1)
	assert.NotEqual(t, id1, id3)

	// Hex round-trip.
	parsed, err := ParseItemID(id1.String())
	require.NoError(t, err)
	assert.Equal(t, id1, parsed)
}

// --- Spec test vectors ------------------------------------------------------

// TestVector_TopicCreation matches the worked example in the spec's
// "Test Vectors" section.
func TestVector_TopicCreation(t *testing.T) {
	tc := TopicCreation{
		Topic:         Topic{0x48, 0x4e, 0x53, 0x21},
		RetentionDays: 0x1e, // 30
		Name:          "Hacker News",
	}
	got, err := EncodeTopicCreation(tc)
	require.NoError(t, err)

	wantHex := "434e0148" + "4e53211e" + "0b" + hex.EncodeToString([]byte("Hacker News"))
	assert.Equal(t, wantHex, hex.EncodeToString(got))

	// Round-trip through the dispatcher.
	tag, msg, err := DecodeMessage(got)
	require.NoError(t, err)
	require.Equal(t, TypeTopicCreation, tag)
	roundTripped := msg.(*TopicCreation)
	assert.Equal(t, tc, *roundTripped)
}

// TestVector_VoteEnvelopeIs111Bytes pins the spec §8 invariant: a Vote
// envelope is exactly 111 bytes regardless of pubkey or sig contents.
// A regression here means the on-chain footprint of every vote
// changes — strictly observable to anyone scanning blocks.
func TestVector_VoteEnvelopeIs111Bytes(t *testing.T) {
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)

	var target ItemID
	_, _ = rand.Read(target[:])

	digest := VoteSigHash(TypeUpvote, target)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	var v Vote
	v.Kind = TypeUpvote
	v.Target = target
	copy(v.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(v.Sig[:], sig.Serialize())

	encoded, err := EncodeVote(v)
	require.NoError(t, err)
	assert.Equal(t, 111, len(encoded), "Vote envelope must be exactly 111 B per spec §8")
}

// TestStoryRoundTripWithTLV proves the TLV section survives encode →
// decode without losing tag order or value bytes — the multi-value
// `url` semantics depend on it.
func TestStoryRoundTripWithTLV(t *testing.T) {
	s := Story{
		Topic:    Topic{0x48, 0x4e, 0x53, 0x21},
		Headline: "Microsoft and OpenAI end revenue-sharing deal",
		TLVs: []TLV{
			{Tag: TLVSubtype, Value: []byte{byte(SubtypeLink)}},
			{Tag: TLVURL, Value: []byte("https://www.bloomberg.com/news/articles/example")},
			{Tag: TLVURL, Value: []byte("https://archive.is/example")}, // gallery
			{Tag: TLVLang, Value: []byte("en")},
		},
	}
	enc, err := EncodeStory(s)
	require.NoError(t, err)

	tag, msg, err := DecodeMessage(enc)
	require.NoError(t, err)
	require.Equal(t, TypeStory, tag)
	got := msg.(*Story)

	assert.Equal(t, s.Topic, got.Topic)
	assert.Equal(t, s.Headline, got.Headline)
	require.Len(t, got.TLVs, 4)
	assert.Equal(t, s.TLVs, got.TLVs)

	// First-wins for single-value tags.
	subtype := FindFirst(got.TLVs, TLVSubtype)
	require.NotNil(t, subtype)
	assert.Equal(t, byte(SubtypeLink), subtype.Value[0])

	// All-wins for multi-value tags.
	urls := FindAll(got.TLVs, TLVURL)
	assert.Len(t, urls, 2)
}

// TestCommentSignatureRoundTrip proves a Comment encoded with a real
// Schnorr sig verifies after decode — the CommentSigHash domain
// separation must match between encode-side and verify-side.
func TestCommentSignatureRoundTrip(t *testing.T) {
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)

	var parent ItemID
	_, _ = rand.Read(parent[:])

	tlvs := []TLV{
		{Tag: TLVBody, Value: []byte("Looks good. ship it.")},
		{Tag: TLVLang, Value: []byte("en")},
	}
	blob, err := SerialiseTLVs(tlvs)
	require.NoError(t, err)

	digest := CommentSigHash(parent, blob)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	var c Comment
	c.Parent = parent
	copy(c.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(c.Sig[:], sig.Serialize())
	c.TLVs = tlvs

	enc, err := EncodeComment(c)
	require.NoError(t, err)

	_, msg, err := DecodeMessage(enc)
	require.NoError(t, err)
	got := msg.(*Comment)
	require.NoError(t, VerifyComment(got))

	// Tamper with the body and verify rejects.
	got.TLVs[0].Value = []byte("ACTUALLY don't ship it")
	assert.ErrorIs(t, VerifyComment(got), ErrBadSignature)
}

// TestVoteSignatureRoundTrip mirrors the comment test and additionally
// proves the typetag is part of the digest — flipping up→down without
// re-signing must fail (spec §8 first-wins replay protection).
func TestVoteSignatureRoundTrip(t *testing.T) {
	priv, err := btcec.NewPrivateKey()
	require.NoError(t, err)

	var target ItemID
	_, _ = rand.Read(target[:])

	digest := VoteSigHash(TypeUpvote, target)
	sig, err := schnorr.Sign(priv, digest[:])
	require.NoError(t, err)

	var v Vote
	v.Kind = TypeUpvote
	v.Target = target
	copy(v.AuthorXPK[:], schnorr.SerializePubKey(priv.PubKey()))
	copy(v.Sig[:], sig.Serialize())

	enc, err := EncodeVote(v)
	require.NoError(t, err)
	_, msg, err := DecodeMessage(enc)
	require.NoError(t, err)
	got := msg.(*Vote)
	require.NoError(t, VerifyVote(got))

	// Flip kind to downvote without re-signing — sig must fail.
	got.Kind = TypeDownvote
	assert.ErrorIs(t, VerifyVote(got), ErrBadSignature, "typetag flip must invalidate the sig")
}

// TestNotCoinNewsTraffic proves the dispatcher's classification: any
// payload that doesn't start with "CN" reports ErrNotCoinNews so the
// indexer's "skip" path fires instead of erroring out.
func TestNotCoinNewsTraffic(t *testing.T) {
	for _, p := range [][]byte{
		nil,
		{},
		{'C'},                        // half-magic
		{'C', 'X', 0x01},             // wrong magic
		{'C', 'N'},                   // magic but no type
		{'X', 'X', 0x01, 0x00, 0x00}, // some other protocol
	} {
		_, _, err := DecodeMessage(p)
		assert.ErrorIs(t, err, ErrNotCoinNews, "payload %x", p)
	}
}

// TestUnknownTypeTagDistinct proves an unknown TypeTag (magic matched
// but the byte after isn't a known type) returns ErrUnknownTypeTag,
// NOT ErrNotCoinNews — telemetry distinguishes "future protocol
// version" from "wrong protocol entirely."
func TestUnknownTypeTagDistinct(t *testing.T) {
	_, _, err := DecodeMessage([]byte{'C', 'N', 0xff, 0x00, 0x00})
	assert.ErrorIs(t, err, ErrUnknownTypeTag, "unknown TypeTag must surface as ErrUnknownTypeTag")
	assert.NotErrorIs(t, err, ErrNotCoinNews, "ErrUnknownTypeTag must be distinct from ErrNotCoinNews")
}

// TestContinuationChunkBound rejects oversize chunks: §9 caps a single
// continuation at 63 bytes so a head + 8 chunks fits the 8 KiB
// reassembly cap with room for the envelope.
func TestContinuationChunkBound(t *testing.T) {
	c := Continuation{
		Head:  ItemID{1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12},
		Seq:   0,
		Chunk: bytes.Repeat([]byte{0xaa}, ContinuationChunk+1),
	}
	_, err := EncodeContinuation(c)
	assert.Error(t, err)

	c.Chunk = bytes.Repeat([]byte{0xaa}, ContinuationChunk)
	enc, err := EncodeContinuation(c)
	require.NoError(t, err)

	tag, msg, err := DecodeMessage(enc)
	require.NoError(t, err)
	assert.Equal(t, TypeContinuation, tag)
	got := msg.(*Continuation)
	assert.Equal(t, c.Head, got.Head)
	assert.Equal(t, c.Seq, got.Seq)
	assert.Equal(t, c.Chunk, got.Chunk)
}
