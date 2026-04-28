package coinnews

import (
	"errors"
	"fmt"
)

// ErrNotCoinNews indicates the payload's leading bytes don't match the
// "CN" magic — this OP_RETURN belongs to some other application.
// Indexers SHOULD treat this as "skip, not error".
var ErrNotCoinNews = errors.New("coinnews: payload is not a CoinNews message")

// ErrUnknownTypeTag indicates the magic matched but the TypeTag isn't
// one this codec knows about. Per spec §1 a future protocol revision
// may define new tags — current indexers MUST drop the message, but
// keeping the error distinct from ErrNotCoinNews preserves telemetry
// (a sudden uptick in unknown tags ⇒ a newer publisher is on chain).
var ErrUnknownTypeTag = errors.New("coinnews: unknown type tag")

// DecodeMessage classifies the payload and returns one of:
//
//	*TopicCreation, *Story, *Comment, *Vote, *Continuation
//
// plus the TypeTag for switch-friendly dispatch. Returns ErrNotCoinNews
// for non-CoinNews traffic; any other error means the bytes claimed to
// be CoinNews but failed to parse.
func DecodeMessage(payload []byte) (TypeTag, any, error) {
	if len(payload) < MagicLen+TypeTagLen {
		return 0, nil, ErrNotCoinNews
	}
	if payload[0] != Magic[0] || payload[1] != Magic[1] {
		return 0, nil, ErrNotCoinNews
	}
	tag := TypeTag(payload[MagicLen])
	body := payload[MagicLen+TypeTagLen:]

	switch tag {
	case TypeTopicCreation:
		t, err := decodeTopicCreation(body)
		return tag, t, err
	case TypeStory:
		s, err := decodeStory(body)
		return tag, s, err
	case TypeComment:
		c, err := decodeComment(body)
		return tag, c, err
	case TypeUpvote, TypeDownvote:
		v, err := decodeVote(tag, body)
		return tag, v, err
	case TypeContinuation:
		c, err := decodeContinuation(body)
		return tag, c, err
	default:
		// Unknown TypeTag: the magic matched, so the publisher
		// intended this as a CoinNews message, but we don't know how
		// to parse it. Per spec §1, indexers MUST drop unknown tags —
		// callers treat this as a skip, but the distinct error keeps
		// telemetry useful.
		return 0, nil, ErrUnknownTypeTag
	}
}

func decodeTopicCreation(b []byte) (*TopicCreation, error) {
	if len(b) < TopicLen+1 {
		return nil, fmt.Errorf("coinnews: topic creation truncated")
	}
	var t TopicCreation
	copy(t.Topic[:], b[:TopicLen])
	t.RetentionDays = b[TopicLen]
	rest := b[TopicLen+1:]
	n, consumed, err := decodeCompactSize(rest)
	if err != nil {
		return nil, fmt.Errorf("coinnews: topic name length: %w", err)
	}
	rest = rest[consumed:]
	if uint64(len(rest)) < n {
		return nil, fmt.Errorf("coinnews: topic name truncated: need %d, have %d", n, len(rest))
	}
	t.Name = string(rest[:n])
	if uint64(len(rest)) > n {
		return nil, fmt.Errorf("coinnews: topic creation has %d trailing bytes", uint64(len(rest))-n)
	}
	return &t, nil
}

func decodeStory(b []byte) (*Story, error) {
	if len(b) < TopicLen+1 {
		return nil, fmt.Errorf("coinnews: story truncated before headline")
	}
	var s Story
	copy(s.Topic[:], b[:TopicLen])
	rest := b[TopicLen:]
	n, consumed, err := decodeCompactSize(rest)
	if err != nil {
		return nil, fmt.Errorf("coinnews: headline length: %w", err)
	}
	rest = rest[consumed:]
	if uint64(len(rest)) < n {
		return nil, fmt.Errorf("coinnews: headline truncated: need %d, have %d", n, len(rest))
	}
	s.Headline = string(rest[:n])
	rest = rest[n:]
	if len(rest) > 0 {
		tlvs, err := DecodeTLVs(rest)
		if err != nil {
			return nil, fmt.Errorf("coinnews: story tlvs: %w", err)
		}
		s.TLVs = tlvs
	}
	return &s, nil
}

func decodeComment(b []byte) (*Comment, error) {
	const fixed = ItemIDLen + XOnlyPubKeyLen + SchnorrSigLen
	if len(b) < fixed {
		return nil, fmt.Errorf("coinnews: comment truncated: need %d, have %d", fixed, len(b))
	}
	var c Comment
	copy(c.Parent[:], b[:ItemIDLen])
	copy(c.AuthorXPK[:], b[ItemIDLen:ItemIDLen+XOnlyPubKeyLen])
	copy(c.Sig[:], b[ItemIDLen+XOnlyPubKeyLen:fixed])
	rest := b[fixed:]
	if len(rest) > 0 {
		tlvs, err := DecodeTLVs(rest)
		if err != nil {
			return nil, fmt.Errorf("coinnews: comment tlvs: %w", err)
		}
		c.TLVs = tlvs
	}
	return &c, nil
}

// VerifyComment is the convenience wrapper indexers use: decode + check
// the signature. Returns ErrBadSignature for failed sig verification.
// Bad framing is returned verbatim from DecodeMessage.
func VerifyComment(c *Comment) error {
	blob, err := SerialiseTLVs(c.TLVs)
	if err != nil {
		return err
	}
	if !VerifyCommentSig(c.AuthorXPK, c.Parent, blob, c.Sig) {
		return ErrBadSignature
	}
	return nil
}

func decodeVote(tag TypeTag, b []byte) (*Vote, error) {
	if len(b) != ItemIDLen+XOnlyPubKeyLen+SchnorrSigLen {
		return nil, fmt.Errorf("coinnews: vote size %d, want %d", len(b), ItemIDLen+XOnlyPubKeyLen+SchnorrSigLen)
	}
	v := &Vote{Kind: tag}
	copy(v.Target[:], b[:ItemIDLen])
	copy(v.AuthorXPK[:], b[ItemIDLen:ItemIDLen+XOnlyPubKeyLen])
	copy(v.Sig[:], b[ItemIDLen+XOnlyPubKeyLen:])
	return v, nil
}

// VerifyVote is the indexer-side counterpart to VerifyComment.
func VerifyVote(v *Vote) error {
	if !VerifyVoteSig(v.AuthorXPK, v.Kind, v.Target, v.Sig) {
		return ErrBadSignature
	}
	return nil
}

func decodeContinuation(b []byte) (*Continuation, error) {
	if len(b) <= ItemIDLen+1 {
		// Header-only continuations are meaningless — they let a
		// publisher pad block space without contributing payload.
		return nil, fmt.Errorf("coinnews: continuation chunk must be non-empty")
	}
	if len(b) > ItemIDLen+1+ContinuationChunk {
		return nil, fmt.Errorf("coinnews: continuation chunk %d > %d", len(b)-ItemIDLen-1, ContinuationChunk)
	}
	var c Continuation
	copy(c.Head[:], b[:ItemIDLen])
	c.Seq = b[ItemIDLen]
	c.Chunk = append([]byte{}, b[ItemIDLen+1:]...)
	return &c, nil
}
