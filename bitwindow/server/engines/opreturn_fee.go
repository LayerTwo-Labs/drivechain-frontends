package engines

import "github.com/btcsuite/btcd/wire"

// OpReturnOutputVbytes is the on-chain cost of one OP_RETURN output that holds
// payloadLen bytes: 8 value + script length + OP_RETURN + the push opcode.
func OpReturnOutputVbytes(payloadLen int) uint64 {
	push := 1
	switch {
	case payloadLen > 0xffff:
		push = 5
	case payloadLen > 0xff:
		push = 3
	case payloadLen > 75:
		push = 2
	}
	scriptLen := 1 + push + payloadLen
	return uint64(8+wire.VarIntSerializeSize(uint64(scriptLen))) + uint64(scriptLen)
}

// OpReturnTxVbytes sizes the transaction that holds an OP_RETURN payload:
// one segwit input, one change output, and the payload output.
func OpReturnTxVbytes(payloadLen int) uint64 {
	return uint64(InputVbytes+OutputVbytes+OverheadVbytes) + OpReturnOutputVbytes(payloadLen)
}
