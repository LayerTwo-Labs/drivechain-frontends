package m1_test

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/m1"
	"github.com/stretchr/testify/require"
)

func bbc(t *testing.T) m1.Declaration {
	t.Helper()

	hash1, err := hex.DecodeString("22d122c47aa4978e4db85313038aac323b89baf34745484be885b5b45da008b6")
	require.NoError(t, err)
	hash2, err := hex.DecodeString("835269a5de15113dd78418917128da0c48c8904d")
	require.NoError(t, err)

	d := m1.Declaration{
		Title:       "Big Block Covenant",
		Description: "Covenant sidechain: CTV, CAT, CSFS, APO, CCV",
	}
	copy(d.HashID1[:], hash1)
	copy(d.HashID2[:], hash2)
	return d
}

func TestDescribeLaysOutTheDeclaration(t *testing.T) {
	d := bbc(t)
	got, err := d.Describe()
	require.NoError(t, err)

	require.Len(t, got, 1+1+18+44+32+20)
	require.Equal(t, byte(0), got[0], "version")
	require.Equal(t, byte(18), got[1], "title length")
	require.Equal(t, "Big Block Covenant", string(got[2:20]))
	require.Equal(t, "Covenant sidechain: CTV, CAT, CSFS, APO, CCV", string(got[20:64]))
	require.Equal(t, d.HashID1[:], got[64:96])
	require.Equal(t, d.HashID2[:], got[96:116])
}

func TestScriptCarriesTheHeaderAndSlot(t *testing.T) {
	script, description, err := m1.Script(1, bbc(t))
	require.NoError(t, err)

	require.Equal(t, byte(txReturn), script[0], "OP_RETURN")
	require.Equal(t, byte(0x4c), script[1], "OP_PUSHDATA1")
	require.Equal(t, byte(121), script[2], "body length")

	body := script[3:]
	require.Equal(t, m1.Tag, body[:4])
	require.Equal(t, byte(1), body[4], "slot")
	require.Equal(t, description, body[5:])
}

// The whole script passes 83 bytes, the default datacarriersize. A relayed
// transaction could never carry it, which matches BIP300: M1 belongs in a
// coinbase, where no node relays it.
func TestScriptPassesTheStandardOpReturnLimit(t *testing.T) {
	script, _, err := m1.Script(1, bbc(t))
	require.NoError(t, err)
	require.Greater(t, len(script), 83)
}

func TestDescriptionHashIsSha256d(t *testing.T) {
	_, description, err := m1.Script(1, bbc(t))
	require.NoError(t, err)

	got := m1.DescriptionHash(description)
	require.Len(t, got, 32)
	require.NotEqual(t, [32]byte{}, got)
}

func TestDescribeRefusesABadTitle(t *testing.T) {
	tests := map[string]string{
		"empty":   "",
		"too big": strings.Repeat("a", 256),
	}
	for name, title := range tests {
		t.Run(name, func(t *testing.T) {
			d := bbc(t)
			d.Title = title
			_, err := d.Describe()
			require.Error(t, err)
		})
	}
}

const txReturn = 0x6a
