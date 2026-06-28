package bip329_test

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bip329"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestEncodeDecodeRoundTrip(t *testing.T) {
	t.Parallel()

	in := []bip329.Label{
		{Type: bip329.TypeTx, Ref: "abc", Label: "coffee"},
		{Type: bip329.TypeAddr, Ref: "bc1qxyz", Label: "donations"},
		{Type: bip329.TypeOutput, Ref: "abc:0", Label: "change"},
	}

	jsonl, err := bip329.Encode(in)
	require.NoError(t, err)

	out, skipped := bip329.Decode(jsonl)
	assert.Equal(t, 0, skipped)
	assert.Equal(t, in, out)
}

func TestDecodeSkipsBlankAndMalformed(t *testing.T) {
	t.Parallel()

	jsonl := `{"type":"tx","ref":"abc","label":"coffee"}

not json at all
{"type":"addr","ref":"bc1q","label":"x","origin":"wpkh([d34db33f])","extra":true}
` // trailing newline + blank line + malformed line + unknown field

	out, skipped := bip329.Decode(jsonl)
	assert.Equal(t, 1, skipped)
	require.Len(t, out, 2)
	assert.Equal(t, "coffee", out[0].Label)
	assert.Equal(t, "wpkh([d34db33f])", out[1].Origin)
}
