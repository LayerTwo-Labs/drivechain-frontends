package engines

// OpReturnOutputVbytes is the on-chain cost of one OP_RETURN output carrying
// payloadLen bytes: 8 value + script length + OP_RETURN + the push opcode.
func OpReturnOutputVbytes(payloadLen int) uint64 {
	push := 1
	if payloadLen > 75 {
		push = 2
	}
	return uint64(8 + 1 + 1 + push + payloadLen)
}

// OpReturnTxVbytes sizes the transaction that carries an OP_RETURN payload:
// one segwit input, one change output, and the payload output.
func OpReturnTxVbytes(payloadLen int) uint64 {
	return uint64(p2wpkhInputVbytes+SweepOutputVbytes+sweepOverheadVbytes) + OpReturnOutputVbytes(payloadLen)
}
