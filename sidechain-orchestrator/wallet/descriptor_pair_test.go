package wallet

import (
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	pairReceive = "wsh(sortedmulti(2," +
		"[b2f4d92a/84'/0'/0']xpub6C8oRaMwxdohB49v3ocWV3DrNUE8yiJxHb3xTzX3xK5pKGVaYuZb7DUb9Gwtzsk4WNjtiVxepgdGzpYAB5Wyi6JBCMGDzQp8J7f5BqkCxUu/0/*," +
		"[9b6e085c/84'/0'/0']xpub6CFFGtwVo4L2AKPoz3uksLjQsk13Ms7dJqedsNsZQr3KkwKBbmGv1o14n7w6eFb9Gvp13n1DUN7z7M5Lgv1RHLZ7wLkWWsVuTe6GRBJHpJK/0/*," +
		"[c02ce165/84'/0'/0']xpub6ByySvFXQL8gNcTKsvzaS6kzdqbRCUcrxP6uDCbJoWBrp3kR7EdUe9NWGAUSYK7W4Qr493MYRprA2TLRGF8ypNywUfMZtDjSTZXYCM1mZfP/0/*))"
)

var pairChange = strings.ReplaceAll(pairReceive, "/0/*", "/1/*")

func TestJoinDescriptorPair(t *testing.T) {
	withSum := func(d string) string {
		s, err := AddDescriptorChecksum(d)
		require.NoError(t, err)
		return s
	}
	for name, text := range map[string]string{
		"one descriptor":  pairReceive,
		"labeled pair":    "External: " + pairReceive + "\n\nInternal: " + pairChange,
		"label on a line": "Receive descriptor:\n" + pairReceive + "\nChange descriptor:\n" + pairChange,
		"unlabeled pair":  pairReceive + "\n" + pairChange,
		"change first":    pairChange + " " + pairReceive,
		"label, no space": "external:" + pairReceive + "\ninternal:" + pairChange,
		"spaces in keys":  strings.ReplaceAll(pairReceive, ",", ", ") + "\n" + strings.ReplaceAll(pairChange, ",", ",\n  "),
		"pair with sums":  withSum(pairReceive) + "\n" + withSum(pairChange),
	} {
		t.Run(name, func(t *testing.T) {
			got, err := JoinDescriptorPair(text)
			require.NoError(t, err)
			d, err := ParseDescriptor(got)
			require.NoError(t, err)
			want, err := ParseDescriptor(pairReceive)
			require.NoError(t, err)
			assert.Equal(t, want, d)
		})
	}
}

func TestJoinDescriptorPairRejects(t *testing.T) {
	other := strings.Replace(pairChange, "sortedmulti(2,", "sortedmulti(1,", 1)
	for name, text := range map[string]string{
		"two receive":  pairReceive + "\n" + pairReceive,
		"other wallet": pairReceive + "\n" + other,
		"three":        pairReceive + "\n" + pairChange + "\n" + pairChange,
		"bad checksum": pairReceive + "#aaaaaaaa\n" + pairChange,
	} {
		t.Run(name, func(t *testing.T) {
			_, err := JoinDescriptorPair(text)
			assert.Error(t, err)
		})
	}
}

func TestValidateDescriptorPair(t *testing.T) {
	policy, err := ValidateDescriptor("External: " + pairReceive + "\n\nInternal: " + pairChange)
	require.NoError(t, err)

	assert.True(t, policy.Multisig)
	assert.Equal(t, "wsh", policy.ScriptType)
	assert.Equal(t, 2, policy.M)
	assert.Equal(t, 3, policy.N)
	assert.Equal(t, pairReceive, policy.Descriptor)
	fingerprints := make([]string, 0, len(policy.Cosigners))
	for _, c := range policy.Cosigners {
		fingerprints = append(fingerprints, c.Fingerprint)
		assert.Equal(t, "84'/0'/0'", c.OriginPath)
	}
	assert.Equal(t, []string{"b2f4d92a", "9b6e085c", "c02ce165"}, fingerprints)
}
