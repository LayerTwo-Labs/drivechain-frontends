package engines_test

import (
	"encoding/hex"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/stretchr/testify/require"
)

func mustHex(t *testing.T, s string) []byte {
	t.Helper()
	b, err := hex.DecodeString(s)
	require.NoError(t, err)
	return b
}

func TestDecodeBase58Check(t *testing.T) {
	cases := []struct {
		name          string
		input         string
		wantVersion   int
		wantPayload   string
		wantChecksum  bool
		wantAddrType  string
		wantErrString string
	}{
		{
			name:         "P2PKH address",
			input:        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2",
			wantVersion:  0x00,
			wantPayload:  "77bff20c60e522dfaa3350c39b030a5d004e839a",
			wantChecksum: true,
			wantAddrType: "P2PKH (Pay-to-PubKey-Hash) - Mainnet",
		},
		{
			name:         "leading zero bytes",
			input:        "1111111111111111111114oLvT2",
			wantVersion:  0x00,
			wantPayload:  "0000000000000000000000000000000000000000",
			wantChecksum: true,
			wantAddrType: "P2PKH (Pay-to-PubKey-Hash) - Mainnet",
		},
		{
			name:         "WIF private key",
			input:        "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ",
			wantVersion:  0x80,
			wantPayload:  "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d",
			wantChecksum: true,
			wantAddrType: "Private Key (WIF) - Mainnet",
		},
		{
			name:         "bad checksum",
			input:        "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN3",
			wantVersion:  0x00,
			wantPayload:  "77bff20c60e522dfaa3350c39b030a5d004e839a",
			wantChecksum: false,
			wantAddrType: "P2PKH (Pay-to-PubKey-Hash) - Mainnet",
		},
		{
			name:          "invalid character",
			input:         "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN0",
			wantErrString: "invalid Base58",
		},
		{
			name:          "too short",
			input:         "1",
			wantErrString: "too short",
		},
		{
			name:          "empty",
			input:         "",
			wantErrString: "too short",
		},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := engines.DecodeBase58Check(tc.input)
			if tc.wantErrString != "" {
				require.ErrorContains(t, err, tc.wantErrString)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tc.wantVersion, got.VersionByte)
			require.Equal(t, mustHex(t, tc.wantPayload), got.Payload)
			require.Equal(t, tc.wantChecksum, got.ChecksumValid)
			require.Equal(t, tc.wantAddrType, got.AddressType)
		})
	}
}

func TestEncodeBase58Check(t *testing.T) {
	cases := []struct {
		name    string
		version int
		data    string
		want    string
	}{
		{"P2PKH address", 0x00, "77bff20c60e522dfaa3350c39b030a5d004e839a", "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2"},
		{"leading zero bytes", 0x00, "0000000000000000000000000000000000000000", "1111111111111111111114oLvT2"},
		{"WIF private key", 0x80, "0c28fca386c7a227600b2fe50b7cae11ec86d3bf1fbe471be89827e19d72aa1d", "5HueCGU8rMjxEXxiPuD5BDku4MkFqeZyd4dZ1jvhTVqvbTLvyTJ"},
		{"P2SH address", 0x05, "8f55563b9a19f321c211e9b9f38cdf686ea07845", "3EktnHQD7RiAE6uzMj2ZifT9YgRrkSgzQX"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got, err := engines.EncodeBase58Check(tc.version, mustHex(t, tc.data))
			require.NoError(t, err)
			require.Equal(t, tc.want, got)

			decoded, err := engines.DecodeBase58Check(got)
			require.NoError(t, err)
			require.True(t, decoded.ChecksumValid)
		})
	}
}
