package coinnews

import (
	"encoding/binary"
	"fmt"
	"io"
)

// CompactSize encodes Bitcoin's compact-size varint per spec §2:
//
//	0x00..0xfc       -> 1 byte
//	0xfd + uint16 LE -> 3 bytes
//	0xfe + uint32 LE -> 5 bytes
//	0xff is reserved.
//
// The 0xff (8-byte) form is rejected on decode so we can never produce
// a Message larger than the 8 KiB reassembly cap (§9).
func encodeCompactSize(w writer, n uint64) error {
	switch {
	case n < 0xfd:
		return w.WriteByte(byte(n))
	case n <= 0xffff:
		if err := w.WriteByte(0xfd); err != nil {
			return err
		}
		var buf [2]byte
		binary.LittleEndian.PutUint16(buf[:], uint16(n))
		_, err := w.Write(buf[:])
		return err
	case n <= 0xffffffff:
		if err := w.WriteByte(0xfe); err != nil {
			return err
		}
		var buf [4]byte
		binary.LittleEndian.PutUint32(buf[:], uint32(n))
		_, err := w.Write(buf[:])
		return err
	default:
		return fmt.Errorf("coinnews: length %d exceeds uint32 (>2^32-1); the 0xff varint form is reserved", n)
	}
}

// decodeCompactSize reads one compact-size varint and returns its value
// plus the number of bytes consumed. Rejects 0xff; the caller can re-
// derive remaining bytes by slicing past the consumed prefix.
func decodeCompactSize(b []byte) (uint64, int, error) {
	if len(b) == 0 {
		return 0, 0, io.ErrUnexpectedEOF
	}
	first := b[0]
	switch {
	case first < 0xfd:
		return uint64(first), 1, nil
	case first == 0xfd:
		if len(b) < 3 {
			return 0, 0, io.ErrUnexpectedEOF
		}
		v := binary.LittleEndian.Uint16(b[1:3])
		// Reject non-canonical encodings: an 0xfd-prefixed value below
		// 0xfd should have been encoded as a single byte.
		if v < 0xfd {
			return 0, 0, fmt.Errorf("coinnews: non-canonical compact-size encoding (0xfd of %d)", v)
		}
		return uint64(v), 3, nil
	case first == 0xfe:
		if len(b) < 5 {
			return 0, 0, io.ErrUnexpectedEOF
		}
		v := binary.LittleEndian.Uint32(b[1:5])
		if v <= 0xffff {
			return 0, 0, fmt.Errorf("coinnews: non-canonical compact-size encoding (0xfe of %d)", v)
		}
		return uint64(v), 5, nil
	default:
		// 0xff form is reserved. We never accept lengths > 2^32 anyway
		// because the reassembly cap (§9) is 8 KiB.
		return 0, 0, fmt.Errorf("coinnews: 0xff compact-size encoding is reserved")
	}
}
