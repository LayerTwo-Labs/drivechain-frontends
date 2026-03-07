package wallet

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/tyler-smith/go-bip39"
)

func TestGenerateMnemonic(t *testing.T) {
	mnemonic, err := GenerateMnemonic()
	require.NoError(t, err)

	words := strings.Fields(mnemonic)
	assert.Equal(t, 12, len(words), "should generate 12-word mnemonic")
	assert.True(t, bip39.IsMnemonicValid(mnemonic), "mnemonic should be valid")
}

func TestGenerateMnemonicUniqueness(t *testing.T) {
	// Generate multiple mnemonics, they should all be unique
	mnemonics := make(map[string]bool)
	for i := 0; i < 10; i++ {
		m, err := GenerateMnemonic()
		require.NoError(t, err)
		assert.False(t, mnemonics[m], "mnemonic should be unique: %s", m)
		mnemonics[m] = true
	}
}

func TestGenerateMnemonicAllWordsValid(t *testing.T) {
	mnemonic, err := GenerateMnemonic()
	require.NoError(t, err)

	wordList := bip39.GetWordList()
	wordSet := make(map[string]bool)
	for _, w := range wordList {
		wordSet[w] = true
	}

	for _, word := range strings.Fields(mnemonic) {
		assert.True(t, wordSet[word], "word %q should be in BIP39 word list", word)
	}
}

func TestMnemonicToSeed(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed := MnemonicToSeed(mnemonic, "")
	assert.Len(t, seed, 64, "seed should be 64 bytes")

	// Known test vector for this mnemonic (no passphrase)
	expectedHex := "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4"
	assert.Equal(t, expectedHex, hex.EncodeToString(seed), "seed should match BIP39 test vector")
}

func TestMnemonicToSeedWithPassphrase(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed1 := MnemonicToSeed(mnemonic, "")
	seed2 := MnemonicToSeed(mnemonic, "my secret passphrase")

	assert.Len(t, seed2, 64)
	assert.NotEqual(t, seed1, seed2, "different passphrases should produce different seeds")
}

func TestMnemonicToSeedDeterministic(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed1 := MnemonicToSeed(mnemonic, "test")
	seed2 := MnemonicToSeed(mnemonic, "test")
	assert.Equal(t, seed1, seed2, "same mnemonic+passphrase should produce same seed")
}

func TestDeriveStarter(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed := MnemonicToSeed(mnemonic, "")
	seedHex := hex.EncodeToString(seed)

	// Derive L1 starter at m/44'/0'/256'
	l1Mnemonic, err := DeriveStarter(seedHex, "m/44'/0'/256'")
	require.NoError(t, err)
	assert.True(t, bip39.IsMnemonicValid(l1Mnemonic), "derived mnemonic should be valid")
	assert.Equal(t, 12, len(strings.Fields(l1Mnemonic)), "derived mnemonic should be 12 words")

	// Derive again - should be deterministic
	l1Mnemonic2, err := DeriveStarter(seedHex, "m/44'/0'/256'")
	require.NoError(t, err)
	assert.Equal(t, l1Mnemonic, l1Mnemonic2, "derivation should be deterministic")

	// Different path should produce different mnemonic
	scMnemonic, err := DeriveStarter(seedHex, "m/44'/0'/9'")
	require.NoError(t, err)
	assert.NotEqual(t, l1Mnemonic, scMnemonic, "different paths should produce different mnemonics")
}

func TestDeriveStarterAllSidechainSlots(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed := MnemonicToSeed(mnemonic, "")
	seedHex := hex.EncodeToString(seed)

	// Test derivation for various sidechain slots
	slots := []int{0, 1, 5, 9, 100, 255, 256}
	mnemonics := make(map[string]bool)

	for _, slot := range slots {
		path := "m/44'/0'/" + itoa(slot) + "'"
		m, err := DeriveStarter(seedHex, path)
		require.NoError(t, err, "should derive at slot %d", slot)
		assert.True(t, bip39.IsMnemonicValid(m), "mnemonic for slot %d should be valid", slot)
		assert.False(t, mnemonics[m], "slot %d mnemonic should be unique", slot)
		mnemonics[m] = true
	}
}

func TestDeriveStarterInvalidSeedHex(t *testing.T) {
	_, err := DeriveStarter("not-hex", "m/44'/0'/9'")
	assert.Error(t, err)
}

func TestDeriveStarterInvalidPath(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed := MnemonicToSeed(mnemonic, "")
	seedHex := hex.EncodeToString(seed)

	_, err := DeriveStarter(seedHex, "m/abc'/0'/9'")
	assert.Error(t, err)
}

func TestDeriveStarterAtMasterPath(t *testing.T) {
	// Derive at the same path twice should be identical
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	seed := MnemonicToSeed(mnemonic, "")
	seedHex := hex.EncodeToString(seed)

	m1, err := DeriveStarter(seedHex, "m/44'/0'/0'")
	require.NoError(t, err)
	m2, err := DeriveStarter(seedHex, "m/44'/0'/0'")
	require.NoError(t, err)
	assert.Equal(t, m1, m2)
}

func TestGenerateFullWallet(t *testing.T) {
	slots := []SidechainSlot{
		{Slot: 9, Name: "Thunder"},
		{Slot: 5, Name: "BitNames"},
	}

	wallet, err := GenerateFullWallet("Test Wallet", "", "", slots, "enforcer")
	require.NoError(t, err)

	assert.Equal(t, "Test Wallet", wallet.Name)
	assert.Equal(t, 1, wallet.Version)
	assert.NotEmpty(t, wallet.Master.Mnemonic)
	assert.NotEmpty(t, wallet.Master.SeedHex)
	assert.NotEmpty(t, wallet.Master.MasterKey)
	assert.NotEmpty(t, wallet.Master.ChainCode)
	assert.NotEmpty(t, wallet.L1.Mnemonic)
	assert.Equal(t, "Bitcoin Core (Patched)", wallet.L1.Name)
	assert.Len(t, wallet.Sidechains, 2)
	assert.Equal(t, 9, wallet.Sidechains[0].Slot)
	assert.Equal(t, "Thunder", wallet.Sidechains[0].Name)
	assert.NotEmpty(t, wallet.Sidechains[0].Mnemonic)
	assert.Equal(t, "enforcer", wallet.WalletType)

	// Master mnemonic is 12 words
	assert.Equal(t, 12, len(strings.Fields(wallet.Master.Mnemonic)))
	assert.True(t, bip39.IsMnemonicValid(wallet.Master.Mnemonic))

	// L1 mnemonic is 12 words
	assert.Equal(t, 12, len(strings.Fields(wallet.L1.Mnemonic)))
	assert.True(t, bip39.IsMnemonicValid(wallet.L1.Mnemonic))

	// All sidechain mnemonics are 12 words
	for _, sc := range wallet.Sidechains {
		assert.Equal(t, 12, len(strings.Fields(sc.Mnemonic)))
		assert.True(t, bip39.IsMnemonicValid(sc.Mnemonic))
	}

	// Master and derived mnemonics should all be different
	allMnemonics := []string{wallet.Master.Mnemonic, wallet.L1.Mnemonic}
	for _, sc := range wallet.Sidechains {
		allMnemonics = append(allMnemonics, sc.Mnemonic)
	}
	seen := make(map[string]bool)
	for _, m := range allMnemonics {
		assert.False(t, seen[m], "all mnemonics should be unique: %s", m)
		seen[m] = true
	}
}

func TestGenerateFullWalletWithCustomMnemonic(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	wallet, err := GenerateFullWallet("Custom", mnemonic, "", nil, "bitcoinCore")
	require.NoError(t, err)

	assert.Equal(t, mnemonic, wallet.Master.Mnemonic)
	assert.Equal(t, "bitcoinCore", wallet.WalletType)

	// Verify known seed hex for "abandon" mnemonic with no passphrase
	expectedSeedHex := "5eb00bbddcf069084889a8ab9155568165f5c453ccb85e70811aaed6f6da5fc19a5ac40b389cd370d086206dec8aa6c43daea6690f20ad3d8d48b2d2ce9e38e4"
	assert.Equal(t, expectedSeedHex, wallet.Master.SeedHex)
}

func TestGenerateFullWalletInvalidCustomMnemonic(t *testing.T) {
	_, err := GenerateFullWallet("Bad", "invalid mnemonic words that are not real bip39", "", nil, "enforcer")
	assert.Error(t, err)
}

func TestGenerateFullWalletNoSlots(t *testing.T) {
	wallet, err := GenerateFullWallet("No Sidechains", "", "", nil, "enforcer")
	require.NoError(t, err)

	assert.NotEmpty(t, wallet.Master.Mnemonic)
	assert.NotEmpty(t, wallet.L1.Mnemonic)
	assert.Len(t, wallet.Sidechains, 0)
}

func TestGenerateFullWalletDeterministicFromSameMnemonic(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	slots := []SidechainSlot{{Slot: 9, Name: "Thunder"}}

	w1, err := GenerateFullWallet("W1", mnemonic, "", slots, "enforcer")
	require.NoError(t, err)

	w2, err := GenerateFullWallet("W2", mnemonic, "", slots, "enforcer")
	require.NoError(t, err)

	// Same derivations
	assert.Equal(t, w1.Master.SeedHex, w2.Master.SeedHex)
	assert.Equal(t, w1.Master.MasterKey, w2.Master.MasterKey)
	assert.Equal(t, w1.Master.ChainCode, w2.Master.ChainCode)
	assert.Equal(t, w1.L1.Mnemonic, w2.L1.Mnemonic)
	assert.Equal(t, w1.Sidechains[0].Mnemonic, w2.Sidechains[0].Mnemonic)

	// BIP39 metadata should also match
	assert.Equal(t, w1.Master.BIP39Binary, w2.Master.BIP39Binary)
	assert.Equal(t, w1.Master.BIP39Checksum, w2.Master.BIP39Checksum)
	assert.Equal(t, w1.Master.BIP39ChecksumHex, w2.Master.BIP39ChecksumHex)
}

func TestGenerateFullWalletWithPassphrase(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	slots := []SidechainSlot{{Slot: 9, Name: "Thunder"}}

	w1, err := GenerateFullWallet("NoPass", mnemonic, "", slots, "enforcer")
	require.NoError(t, err)

	w2, err := GenerateFullWallet("WithPass", mnemonic, "secret", slots, "enforcer")
	require.NoError(t, err)

	// Same master mnemonic but different seeds and derivations
	assert.Equal(t, w1.Master.Mnemonic, w2.Master.Mnemonic)
	assert.NotEqual(t, w1.Master.SeedHex, w2.Master.SeedHex, "passphrase should change the seed")
	assert.NotEqual(t, w1.L1.Mnemonic, w2.L1.Mnemonic, "passphrase should change derived mnemonics")
	assert.NotEqual(t, w1.Sidechains[0].Mnemonic, w2.Sidechains[0].Mnemonic)
}

func TestGenerateFullWalletBIP39Metadata(t *testing.T) {
	mnemonic := "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	wallet, err := GenerateFullWallet("Meta", mnemonic, "", nil, "enforcer")
	require.NoError(t, err)

	// "abandon" mnemonic has known entropy: 00000000000000000000000000000000 (128 bits = 16 zero bytes)
	assert.NotEmpty(t, wallet.Master.BIP39Binary)
	assert.NotEmpty(t, wallet.Master.BIP39Checksum)
	assert.NotEmpty(t, wallet.Master.BIP39ChecksumHex)

	// Binary should be 128 characters (128 bits of entropy)
	assert.Len(t, wallet.Master.BIP39Binary, 128, "BIP39 binary should be 128 chars for 12-word mnemonic")

	// For the "abandon" mnemonic, entropy is all zeros
	assert.Equal(t, strings.Repeat("0", 128), wallet.Master.BIP39Binary)
}

func TestSerializedPrivateKeyHex(t *testing.T) {
	// Test the helper that formats keys like Dart's privateKeyHex()
	key := make([]byte, 32)
	for i := range key {
		key[i] = byte(i)
	}

	result := serializedPrivateKeyHex(key)
	assert.Len(t, result, 66, "should be 33 bytes = 66 hex chars")
	assert.True(t, strings.HasPrefix(result, "00"), "should start with 00 prefix")
	assert.Equal(t, "00"+hex.EncodeToString(key), result)
}

func TestBytesToBinary(t *testing.T) {
	assert.Equal(t, "00000000", bytesToBinary([]byte{0x00}))
	assert.Equal(t, "11111111", bytesToBinary([]byte{0xff}))
	assert.Equal(t, "0000000011111111", bytesToBinary([]byte{0x00, 0xff}))
	assert.Equal(t, "10101010", bytesToBinary([]byte{0xaa}))
}

func TestCalculateChecksumBits(t *testing.T) {
	// 16 bytes of entropy -> 128 bits -> 4 checksum bits
	entropy := make([]byte, 16)
	checksum := calculateChecksumBits(entropy)
	assert.Len(t, checksum, 4, "16 bytes entropy should give 4 checksum bits")

	// All zeros entropy has known checksum
	// SHA256(16 zero bytes) = 374708fff7719dd5979ec875d56cd2286f6d3cf7ec317a3b25632aab28ec37bb
	// 0x37 = 0011 0111, first 4 bits = 0011
	assert.Equal(t, "0011", checksum)
}

// Helper for itoa without importing strconv
func itoa(n int) string {
	if n == 0 {
		return "0"
	}
	s := ""
	for n > 0 {
		s = string(rune('0'+n%10)) + s
		n /= 10
	}
	return s
}

