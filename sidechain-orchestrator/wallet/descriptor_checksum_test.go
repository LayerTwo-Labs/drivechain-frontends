package wallet

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Vectors from Bitcoin Core's descriptor tests (BIP380). This checksum is a
// hand-rolled port of Core's polymod, so it is pinned against the source.
func TestAddDescriptorChecksum(t *testing.T) {
	t.Parallel()

	cases := []struct {
		name string
		desc string
		want string
	}{
		{
			name: "raw",
			desc: "raw(deadbeef)",
			want: "raw(deadbeef)#89f8spxm",
		},
		{
			name: "wpkh with origin and wildcard",
			desc: "wpkh([d34db33f/84h/0h/0h]xpub6DJ2dNUysrn5Vt36jH2KLBT2i1auw1tTSSomg8PhqNiUtx8QX2SvC9nrHu81fT41fvDUnhMjEzQgXnQjKEu3oaqMSzhSrHMxyyoEAmUHQbY/0/*)",
			want: "wpkh([d34db33f/84h/0h/0h]xpub6DJ2dNUysrn5Vt36jH2KLBT2i1auw1tTSSomg8PhqNiUtx8QX2SvC9nrHu81fT41fvDUnhMjEzQgXnQjKEu3oaqMSzhSrHMxyyoEAmUHQbY/0/*)#cjjspncu",
		},
		{
			name: "sh multi",
			desc: "sh(multi(2,[00000000/111'/222]xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc,xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L/0))",
			want: "sh(multi(2,[00000000/111'/222]xprvA1RpRA33e1JQ7ifknakTFpgNXPmW2YvmhqLQYMmrj4xJXXWYpDPS3xz7iAxn8L39njGVyuoseXzU6rcxFLJ8HFsTjSyQbLYnMpCqE2VbFWc,xprv9uPDJpEQgRQfDcW7BkF7eTya6RPxXeJCqCJGHuCJ4GiRVLzkTXBAJMu2qaMWPrS7AANYqdq6vcBcBUdJCVVFceUvJFjaPdGZ2y9WACViL4L/0))#ggrsrxfy",
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			got, err := AddDescriptorChecksum(tc.desc)
			require.NoError(t, err)
			assert.Equal(t, tc.want, got)
		})
	}
}

// sortedmulti_a is what taproot multisig wallets are stored as, so the
// underscore must survive the input charset.
func TestAddDescriptorChecksumAcceptsSortedMultiA(t *testing.T) {
	t.Parallel()

	desc := "tr(" + numsInternalKeyHex + ",sortedmulti_a(2,xpub661MyMwAqRbcFtXgS5sYJABqqG9YLmC4Q1Rdap9gSE8NqtwybGhePY2gZ29ESFjqJoCu1Rupje8YtGqsefD265TMg7usUDFdp6W1EGMcet8,xpub69H7F5d8KSRgmmdJg2KhpAK8SR3DjMwAdkxj3ZuxV27CprR9LgpeyGmXUbC6wb7ERfvrnKZjXoUhmM8xUR7bmXDDNXA1jQtCF6HZK17MDLd))"
	got, err := AddDescriptorChecksum(desc)
	require.NoError(t, err)
	assert.Regexp(t, `#[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{8}$`, got)
}

func TestAddDescriptorChecksumRejectsInvalidCharacter(t *testing.T) {
	t.Parallel()

	_, err := AddDescriptorChecksum("wpkh(xpub…)")
	require.Error(t, err)
}
