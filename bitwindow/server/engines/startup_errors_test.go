package engines

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestIsBitcoinCoreStartupError(t *testing.T) {
	cases := []struct {
		err  string
		want bool
		name string
	}{
		{"-28: Verifying blocks…", true, "verify"},
		{"loadwallet RPC error -4: Wallet already loading.", true, "wallet-already-loading"},
		{"Still rescanning. At block 470818", true, "still-rescanning"},
		{"some other unrelated error", false, "unrelated"},
		{"", false, "empty"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, IsBitcoinCoreStartupError(tc.err))
		})
	}
}

func TestExtractBitcoindStartupMessage(t *testing.T) {
	cases := []struct {
		name  string
		input string
		want  string
	}{
		{"connect-go internal -28", "internal: -28: Verifying blocks…", "Verifying blocks…"},
		{"dash separator", "getblockcount([]): -28 - Loading block index…", "Loading block index…"},
		{"wallet -4", "loadwallet RPC error -4: Wallet already loading.", "Wallet already loading."},
		{"plain pattern fallthrough", "Rescanning at height 100", "Rescanning at height 100"},
		{"non-startup error returns empty", "permission denied", ""},
		{"empty input returns empty", "", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, ExtractBitcoindStartupMessage(tc.input))
		})
	}
}

// Core deletes its auth cookie when it stops. Every RPC in the restart window
// failed the stat, which the UI showed as an error instead of a boot phase.
func TestMissingCookieReadsAsAStartupError(t *testing.T) {
	const err = "could not get network stats: get blockchain info: unknown: " +
		"stat /media/user/Datadrive/CHAINDATA/Ecash/ecash/.cookie: no such file or directory"

	assert.True(t, IsBitcoinCoreStartupError(err))
	assert.Equal(t, "Starting Bitcoin Core", ExtractBitcoindStartupMessage(err))
}

// A cookie the process may not read is a permission fault, not a boot phase.
func TestUnreadableCookieIsNotAStartupError(t *testing.T) {
	const err = "stat /home/user/.bitcoin/.cookie: permission denied"

	assert.False(t, IsBitcoinCoreStartupError(err))
}

// Windows words the same absent file differently, so the Unix text alone left
// the restart window a hard error on a supported platform.
func TestMissingCookieReadsAsAStartupErrorOnEveryPlatform(t *testing.T) {
	for name, err := range map[string]string{
		"windows file": `CreateFile C:\Users\u\AppData\Roaming\Bitcoin\.cookie: ` +
			"The system cannot find the file specified.",
		"windows path": `CreateFile C:\Users\u\AppData\Roaming\Bitcoin\.cookie: ` +
			"The system cannot find the path specified.",
		"unix": "stat /home/u/.bitcoin/.cookie: no such file or directory",
	} {
		t.Run(name, func(t *testing.T) {
			assert.True(t, IsBitcoinCoreStartupError(err))
			assert.Equal(t, "Starting Bitcoin Core", ExtractBitcoindStartupMessage(err))
		})
	}
}

// rpccookiefile renames the file, so the name cannot be the signal. The
// wrapper that reads it names it instead.
func TestARenamedCookieIsAStartupError(t *testing.T) {
	const err = "read rpc cookie /home/u/.bitcoin/auth-token: " +
		"open /home/u/.bitcoin/auth-token: no such file or directory"
	assert.True(t, IsBitcoinCoreStartupError(err))
	assert.Equal(t, cookieMessage, ExtractBitcoindStartupMessage(err))
}

// A renamed cookie the process may not read is still a permission fault.
func TestARenamedCookieWithNoPermissionIsNotAStartupError(t *testing.T) {
	assert.False(t, IsBitcoinCoreStartupError(
		"read rpc cookie /home/u/.bitcoin/auth-token: permission denied"))
}

// The reason alone must not match. Only a failure about the cookie counts.
func TestAMissingFileThatIsNotTheCookieIsNotAStartupError(t *testing.T) {
	assert.False(t, IsBitcoinCoreStartupError(
		"open /home/u/.bitcoin/wallet.dat: no such file or directory"))
	assert.False(t, IsBitcoinCoreStartupError(
		`CreateFile C:\data\blocks: The system cannot find the file specified.`))
}
