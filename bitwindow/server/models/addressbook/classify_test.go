package addressbook

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
)

// Alice's payment code from the Samourai BIP47 vectors. Real spec-compliant
// v1 payment code (81-byte payload, version byte 0x47).
const samouraiAlicePaymentCode = "PM8TJTLJbPRGxSbc8EJi42Wrr6QbNSaSSVJ5Y3E4pbCYiTHUskHg13935Ubb7q8tx9GVbh2UuRnBc3WSyJHhUrw8KhprKnn9eDznYGieTzFcwQRya4GA"

// buildLegacyBIP47V3 returns the old, non-spec-compliant 39-byte format
// (0x22 || 0x03 || compressed_pubkey(33B) || sha256d[:4]) we used to emit.
// Used here to assert the new classifier rejects it.
func buildLegacyBIP47V3(t *testing.T, compressedPubKey []byte) string {
	t.Helper()
	require.Len(t, compressedPubKey, 33)
	payload := make([]byte, 35)
	payload[0] = 0x22
	payload[1] = 0x03
	copy(payload[2:], compressedPubKey)
	h1 := sha256.Sum256(payload)
	h2 := sha256.Sum256(h1[:])
	payload = append(payload, h2[:4]...)
	return base58.Encode(payload)
}

func depositChecksum(slot int, addr string) string {
	input := fmt.Sprintf("s%d_%s_", slot, addr)
	h := sha256.Sum256([]byte(input))
	return hex.EncodeToString(h[:3])
}

func TestClassifyAddress(t *testing.T) {
	// L1 addresses known to decode against their respective network params.
	const mainnetP2PKH = "1BoatSLRHtKNngkdXEeobR76b53LETtpyT"
	const signetBech32 = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	const regtestBech32 = "bcrt1qw508d6qejxtdg4y5r3zarvary0c5xw7kygt080"

	// Legacy 39-byte v3 format we used to emit before Phase 1. Now treated as
	// unknown — the classifier requires a real spec payment code.
	samplePubKey := make([]byte, 33)
	samplePubKey[0] = 0x02
	for i := 1; i < 33; i++ {
		samplePubKey[i] = byte(i)
	}
	legacyV3Code := buildLegacyBIP47V3(t, samplePubKey)

	goodChecksum := depositChecksum(0, mainnetP2PKH)
	validDeposit := fmt.Sprintf("s0_%s_%s", mainnetP2PKH, goodChecksum)
	badChecksumDeposit := fmt.Sprintf("s0_%s_deadbe", mainnetP2PKH)
	depositWithJunkAddr := fmt.Sprintf("s0_notAnAddress_%s", depositChecksum(0, "notAnAddress"))
	slotOnly := fmt.Sprintf("s9_%s", mainnetP2PKH)

	cases := []struct {
		name  string
		input string
		want  pb.AddressType
	}{
		{"empty", "", pb.AddressType_ADDRESS_TYPE_UNSPECIFIED},
		{"whitespace only", "   ", pb.AddressType_ADDRESS_TYPE_UNSPECIFIED},
		{"garbage", "not-an-address", pb.AddressType_ADDRESS_TYPE_UNKNOWN},

		{"bip47 spec payment code", samouraiAlicePaymentCode, pb.AddressType_ADDRESS_TYPE_BIP47_PAYMENT_CODE},
		{"legacy 39-byte v3 format is not a payment code", legacyV3Code, pb.AddressType_ADDRESS_TYPE_UNKNOWN},

		{"mainnet p2pkh", mainnetP2PKH, pb.AddressType_ADDRESS_TYPE_BITCOIN_L1},
		{"signet bech32", signetBech32, pb.AddressType_ADDRESS_TYPE_BITCOIN_L1},
		{"regtest bech32", regtestBech32, pb.AddressType_ADDRESS_TYPE_BITCOIN_L1},

		// Trim behaviour — trailing newline from paste.
		{"trimmed whitespace around l1", "  " + mainnetP2PKH + "\n", pb.AddressType_ADDRESS_TYPE_BITCOIN_L1},

		{"valid 3-part deposit", validDeposit, pb.AddressType_ADDRESS_TYPE_DRIVECHAIN_DEPOSIT},
		{"deposit with bad checksum", badChecksumDeposit, pb.AddressType_ADDRESS_TYPE_UNKNOWN},
		{"deposit with non-address body", depositWithJunkAddr, pb.AddressType_ADDRESS_TYPE_UNKNOWN},
		{"slot-only no checksum", slotOnly, pb.AddressType_ADDRESS_TYPE_UNKNOWN},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			got := ClassifyAddress(tc.input)
			require.Equal(t, tc.want, got)
		})
	}
}

const bookAddress = "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh"

func TestCreate(t *testing.T) {
	db := database.Test(t)
	walletID := "wallet-a"

	t.Run("a new entry saves", func(t *testing.T) {
		require.NoError(t, Create(t.Context(), db, &walletID, "rent", bookAddress, DirectionSend))
	})

	t.Run("the same address and direction is a duplicate", func(t *testing.T) {
		err := Create(t.Context(), db, &walletID, "other", bookAddress, DirectionSend)
		require.ErrorIs(t, err, ErrDuplicateAddress)
	})

	t.Run("the same address in the other direction saves", func(t *testing.T) {
		require.NoError(t, Create(t.Context(), db, nil, "", bookAddress, DirectionReceive))
	})
}

func TestUpsert(t *testing.T) {
	db := database.Test(t)

	require.NoError(t, Upsert(t.Context(), db, nil, "first", bookAddress, DirectionSend))
	require.NoError(t, Upsert(t.Context(), db, nil, "second", bookAddress, DirectionSend))

	entries, err := List(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, entries, 1)
	require.Equal(t, "second", entries[0].Label)
	require.Equal(t, DirectionSend, entries[0].Direction)
}

func TestLabelsByAddress(t *testing.T) {
	db := database.Test(t)
	require.NoError(t, Create(t.Context(), db, nil, "first", bookAddress, DirectionSend))
	require.NoError(t, Create(t.Context(), db, nil, "second", bookAddress, DirectionReceive))
	require.NoError(t, Create(t.Context(), db, nil, "", "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq", DirectionReceive))

	labels, err := LabelsByAddress(t.Context(), db)
	require.NoError(t, err)
	require.Equal(t, map[string]string{
		bookAddress: "first",
		"bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq": "",
	}, labels)
}

func TestUpdateLabel(t *testing.T) {
	db := database.Test(t)
	require.NoError(t, Create(t.Context(), db, nil, "old", bookAddress, DirectionSend))
	entries, err := List(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, entries, 1)

	t.Run("an entry gets the new label", func(t *testing.T) {
		require.NoError(t, UpdateLabel(t.Context(), db, entries[0].ID, "new"))
		updated, err := List(t.Context(), db)
		require.NoError(t, err)
		require.Equal(t, "new", updated[0].Label)
	})

	t.Run("a missing entry is not found", func(t *testing.T) {
		err := UpdateLabel(t.Context(), db, entries[0].ID+1, "new")
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}

func TestDelete(t *testing.T) {
	db := database.Test(t)
	require.NoError(t, Create(t.Context(), db, nil, "", bookAddress, DirectionSend))
	entries, err := List(t.Context(), db)
	require.NoError(t, err)
	require.Len(t, entries, 1)

	t.Run("an entry deletes", func(t *testing.T) {
		require.NoError(t, Delete(t.Context(), db, entries[0].ID))
		left, err := List(t.Context(), db)
		require.NoError(t, err)
		require.Empty(t, left)
	})

	t.Run("a missing entry is not found", func(t *testing.T) {
		err := Delete(t.Context(), db, entries[0].ID)
		require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})

	t.Run("a failed delete returns the error", func(t *testing.T) {
		closed := database.Test(t)
		require.NoError(t, closed.Close())

		err := Delete(t.Context(), closed, 1)
		require.ErrorContains(t, err, "database is closed")
	})
}
