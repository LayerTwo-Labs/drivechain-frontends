package engines

import (
	"encoding/json"
	"os"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// testdata/converter_frontend.json holds what the Dart converter gave for each input.
type frontendCase struct {
	Input     string     `json:"input"`
	Format    string     `json:"format"`
	Network   string     `json:"network"`
	Detected  string     `json:"detected"`
	Error     bool       `json:"error"`
	Encodings [][]string `json:"encodings"`
	Hashes    [][]string `json:"hashes"`
	Keys      [][]string `json:"keys"`
}

var frontendFormats = map[string]ConverterFormat{
	"auto": ConverterAuto, "hex": ConverterHex, "base64": ConverterBase64, "base58": ConverterBase58,
	"base58check": ConverterBase58Check, "bech32": ConverterBech32, "ascii": ConverterASCII,
	"wif": ConverterWIF, "passphrase": ConverterPassphrase,
}

var frontendNetworks = map[string]*chaincfg.Params{
	"mainnet": &chaincfg.MainNetParams, "ecash": &chaincfg.MainNetParams,
	"signet": &chaincfg.SigNetParams, "regtest": &chaincfg.RegressionNetParams,
}

func rowPairs(rows []ConverterRow) [][]string {
	out := make([][]string, 0, len(rows))
	for _, r := range rows {
		out = append(out, []string{r.Label, r.Value})
	}
	return out
}

// The reason text differs between the two languages; the row stays.
func withoutReason(rows [][]string) [][]string {
	out := make([][]string, 0, len(rows))
	for _, r := range rows {
		if r[0] == "Public key" && strings.HasPrefix(r[1], "not derivable") {
			r = []string{r[0], "not derivable"}
		}
		out = append(out, r)
	}
	return out
}

func TestConvertMatchesFrontend(t *testing.T) {
	raw, err := os.ReadFile("testdata/converter_frontend.json")
	require.NoError(t, err)
	var cases []frontendCase
	require.NoError(t, json.Unmarshal(raw, &cases))
	require.NotEmpty(t, cases)

	for _, c := range cases {
		name := c.Network + " " + c.Format + " " + c.Input
		format, ok := frontendFormats[c.Format]
		require.True(t, ok, name)
		got := Convert(c.Input, format, frontendNetworks[c.Network])

		require.Equal(t, frontendFormats[c.Detected], got.Detected, name)
		require.Equal(t, c.Error, got.Error != "", "%s: %s", name, got.Error)
		require.Equal(t, c.Encodings, rowPairs(got.Encodings), name)
		require.Equal(t, c.Hashes, rowPairs(got.Hashes), name)
		require.Equal(t, withoutReason(c.Keys), withoutReason(rowPairs(got.Keys)), name)
	}
}

func TestConvertKnownVectors(t *testing.T) {
	got := Convert("0000000000000000000000000000000000000000000000000000000000000001", ConverterHex, &chaincfg.MainNetParams)
	keys := map[string]string{}
	for _, r := range got.Keys {
		keys[r.Label] = r.Value
	}
	require.Equal(t, "0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798", keys["Public key (compressed)"])
	require.Equal(t, "KwDiBf89QgGbjEhKnhXJuH7LrciVrZi3qYjgd9M7rFU73sVHnoWn", keys["WIF (compressed)"])
	require.Equal(t, "1BgGZ9tcN4rm9KBzDn7KprQz87SZ26SAMH", keys["P2PKH address"])
	require.Equal(t, "bc1qw508d6qejxtdg4y5r3zarvary0c5xw7kv8f3t4", keys["P2WPKH address"])
}
