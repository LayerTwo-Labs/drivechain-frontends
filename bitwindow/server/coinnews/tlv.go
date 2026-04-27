package coinnews

import (
	"bytes"
	"fmt"
)

// TLV is one Tag-Length-Value tuple (spec §10). Length is implied by
// len(Value) on encode and recovered from the wire on decode.
type TLV struct {
	Tag   TLVTag
	Value []byte
}

// EncodeTLVs writes the concatenation of (tag ‖ varint-length ‖ value)
// for every entry in `tlvs`, preserving caller order. Order is
// significant for first-wins duplicate semantics (spec §10).
func EncodeTLVs(w writer, tlvs []TLV) error {
	for _, t := range tlvs {
		if err := w.WriteByte(byte(t.Tag)); err != nil {
			return err
		}
		if err := encodeCompactSize(w, uint64(len(t.Value))); err != nil {
			return err
		}
		if _, err := w.Write(t.Value); err != nil {
			return err
		}
	}
	return nil
}

// DecodeTLVs walks the byte slice as a sequence of TLVs and returns
// them in wire order. Stops cleanly at the end of the slice; an
// incomplete TLV at the tail is an error (length mismatch).
func DecodeTLVs(b []byte) ([]TLV, error) {
	var out []TLV
	for len(b) > 0 {
		tag := TLVTag(b[0])
		b = b[1:]
		n, consumed, err := decodeCompactSize(b)
		if err != nil {
			return nil, fmt.Errorf("coinnews: tlv length: %w", err)
		}
		b = b[consumed:]
		if uint64(len(b)) < n {
			return nil, fmt.Errorf("coinnews: tlv tag 0x%02x truncated: need %d, have %d", tag, n, len(b))
		}
		v := make([]byte, n)
		copy(v, b[:n])
		out = append(out, TLV{Tag: tag, Value: v})
		b = b[n:]
	}
	return out, nil
}

// FindFirst returns the first TLV with the given tag, or nil if absent.
// Encodes the spec §10 first-wins rule for single-value tags.
func FindFirst(tlvs []TLV, tag TLVTag) *TLV {
	for i := range tlvs {
		if tlvs[i].Tag == tag {
			return &tlvs[i]
		}
	}
	return nil
}

// FindAll returns every TLV with the given tag, in wire order. Encodes
// the multi-value semantics for tags like `url` (gallery support).
func FindAll(tlvs []TLV, tag TLVTag) []TLV {
	var out []TLV
	for _, t := range tlvs {
		if t.Tag == tag {
			out = append(out, t)
		}
	}
	return out
}

// SerialiseTLVs is a convenience wrapper that allocates and returns the
// concatenated bytes — useful for hashing into signatures (Comment's
// tagged hash includes the TLV blob verbatim).
func SerialiseTLVs(tlvs []TLV) ([]byte, error) {
	var buf bytes.Buffer
	if err := EncodeTLVs(&buf, tlvs); err != nil {
		return nil, err
	}
	return buf.Bytes(), nil
}
