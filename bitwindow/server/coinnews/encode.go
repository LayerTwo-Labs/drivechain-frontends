package coinnews

import (
	"bytes"
	"fmt"
)

// EncodeTopicCreation produces the wire bytes for a Topic Creation
// (BIP §5):
//
//	"CN" ‖ 0x01 ‖ topic(4) ‖ retention(1) ‖ name(varint+UTF-8)
func EncodeTopicCreation(t TopicCreation) ([]byte, error) {
	if len(t.Name) > 0xffff {
		return nil, fmt.Errorf("coinnews: topic name too long: %d", len(t.Name))
	}
	var buf bytes.Buffer
	buf.Write(Magic[:])
	buf.WriteByte(byte(TypeTopicCreation))
	buf.Write(t.Topic[:])
	buf.WriteByte(t.RetentionDays)
	if err := encodeCompactSize(&buf, uint64(len(t.Name))); err != nil {
		return nil, err
	}
	buf.WriteString(t.Name)
	return buf.Bytes(), nil
}

// EncodeStory (BIP §6):
//
//	"CN" ‖ 0x02 ‖ topic(4) ‖ headline(varint+UTF-8) ‖ tlv*
func EncodeStory(s Story) ([]byte, error) {
	if len(s.Headline) > HeadlineMaxLen {
		// Not a hard error — long headlines are legal — but we want
		// callers to be aware they're paying a 3-byte varint instead
		// of 1 byte. Returning the headline anyway lets ranking land
		// the post; refusing here would force every wallet to
		// pre-truncate.
	}
	var buf bytes.Buffer
	buf.Write(Magic[:])
	buf.WriteByte(byte(TypeStory))
	buf.Write(s.Topic[:])
	if err := encodeCompactSize(&buf, uint64(len(s.Headline))); err != nil {
		return nil, err
	}
	buf.WriteString(s.Headline)
	if err := EncodeTLVs(&buf, s.TLVs); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// EncodeComment (BIP §7). Caller is responsible for producing a sig
// that covers CommentSigHash(Parent, SerialiseTLVs(TLVs)) — the
// encoder does not re-sign on the fly because callers may want to
// build the bytes once (e.g. for fee preview) before signing.
func EncodeComment(c Comment) ([]byte, error) {
	var buf bytes.Buffer
	buf.Write(Magic[:])
	buf.WriteByte(byte(TypeComment))
	buf.Write(c.Parent[:])
	buf.Write(c.AuthorXPK[:])
	buf.Write(c.Sig[:])
	if err := EncodeTLVs(&buf, c.TLVs); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}

// EncodeVote (BIP §8). Always 111 B — the only CoinNews payload with
// no variable-length section.
func EncodeVote(v Vote) ([]byte, error) {
	if v.Kind != TypeUpvote && v.Kind != TypeDownvote {
		return nil, fmt.Errorf("coinnews: vote kind must be 0x04 or 0x05, got 0x%02x", v.Kind)
	}
	var buf bytes.Buffer
	buf.Write(Magic[:])
	buf.WriteByte(byte(v.Kind))
	buf.Write(v.Target[:])
	buf.Write(v.AuthorXPK[:])
	buf.Write(v.Sig[:])
	if buf.Len() != VoteEnvelopeLen {
		return nil, fmt.Errorf("coinnews: vote encoding produced %d bytes, want %d", buf.Len(), VoteEnvelopeLen)
	}
	return buf.Bytes(), nil
}

// EncodeContinuation (BIP §9).
func EncodeContinuation(c Continuation) ([]byte, error) {
	if len(c.Chunk) > ContinuationChunk {
		return nil, fmt.Errorf("coinnews: continuation chunk %d > %d", len(c.Chunk), ContinuationChunk)
	}
	var buf bytes.Buffer
	buf.Write(Magic[:])
	buf.WriteByte(byte(TypeContinuation))
	buf.Write(c.Head[:])
	buf.WriteByte(c.Seq)
	buf.Write(c.Chunk)
	return buf.Bytes(), nil
}
