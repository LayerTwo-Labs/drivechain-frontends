package engines

import "testing"

func TestOpReturnOutputVbytesUsesTheRightPushOpcode(t *testing.T) {
	// a single-byte push covers payloads up to 75 bytes
	if got := OpReturnOutputVbytes(75); got != 8+1+1+1+75 {
		t.Errorf("75-byte payload: got %d", got)
	}
	// past that the payload needs OP_PUSHDATA1 plus a length byte
	if got := OpReturnOutputVbytes(76); got != 8+1+1+2+76 {
		t.Errorf("76-byte payload: got %d", got)
	}
}

func TestOpReturnTxVbytesCountsInputChangeAndPayload(t *testing.T) {
	// one segwit input (68) + change (31) + overhead (11) + the payload output
	want := uint64(68+31+11) + OpReturnOutputVbytes(40)
	if got := OpReturnTxVbytes(40); got != want {
		t.Errorf("expected %d vbytes, got %d", want, got)
	}
}

func TestOpReturnTxVbytesGrowsWithThePayload(t *testing.T) {
	small := OpReturnTxVbytes(40)
	large := OpReturnTxVbytes(140)
	if large <= small {
		t.Fatalf("a longer payload must cost more: %d vs %d", small, large)
	}
	// 100 more payload bytes, plus the wider push opcode
	if large-small != 101 {
		t.Errorf("expected 101 extra vbytes, got %d", large-small)
	}
}
