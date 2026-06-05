package replay

import (
	"bytes"
	"encoding/hex"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
)

// sampleTxHex builds a minimal, valid version-2 transaction and returns its hex.
func sampleTxHex(t *testing.T) string {
	t.Helper()
	tx := wire.NewMsgTx(2)
	var prev chainhash.Hash
	tx.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&prev, 0), nil, nil))
	tx.AddTxOut(wire.NewTxOut(1000, []byte{0x51})) // OP_TRUE
	var buf bytes.Buffer
	if err := tx.Serialize(&buf); err != nil {
		t.Fatalf("serialize: %v", err)
	}
	return hex.EncodeToString(buf.Bytes())
}

func deserialize(t *testing.T, rawHex string) (*wire.MsgTx, error) {
	t.Helper()
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		t.Fatalf("decode hex: %v", err)
	}
	tx := wire.NewMsgTx(1)
	return tx, tx.Deserialize(bytes.NewReader(raw))
}

func TestSetVersionGivesMagicVersion(t *testing.T) {
	versioned, err := SetVersion(sampleTxHex(t))
	if err != nil {
		t.Fatalf("SetVersion: %v", err)
	}
	if !strings.HasPrefix(versioned, "bfbfbf00") {
		t.Fatalf("version bytes not set: %s", versioned[:8])
	}
	// Still a valid Bitcoin tx — only the version changed.
	tx, err := deserialize(t, versioned)
	if err != nil {
		t.Fatalf("versioned tx should still deserialize: %v", err)
	}
	if tx.Version != TxReplayVersion {
		t.Fatalf("version = %d, want %d", tx.Version, TxReplayVersion)
	}
}

func TestInjectReplayByteBreaksBitcoinDeserialization(t *testing.T) {
	versioned, err := SetVersion(sampleTxHex(t))
	if err != nil {
		t.Fatalf("SetVersion: %v", err)
	}
	injected, err := InjectReplayByte(versioned)
	if err != nil {
		t.Fatalf("InjectReplayByte: %v", err)
	}
	// The whole point: Bitcoin's deserializer cannot read the eCash format, so
	// the tx can't replay onto Bitcoin.
	if _, err := deserialize(t, injected); err == nil {
		t.Fatal("expected Bitcoin deserialization to FAIL on the replay-encoded tx")
	}
}

func TestRejectsBadInput(t *testing.T) {
	if _, err := SetVersion("ab"); err == nil {
		t.Fatal("SetVersion should reject too-short hex")
	}
	if _, err := InjectReplayByte("nothex!!"); err == nil {
		t.Fatal("InjectReplayByte should reject non-hex")
	}
}
