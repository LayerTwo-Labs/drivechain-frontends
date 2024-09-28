package drivechain

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcutil"
)

// DecodeDepositAddress decodes a deposit address string into its components.
// The deposit address format is: slot_address_checksum
// It returns the slot number, the Bitcoin address, the checksum, and any error encountered.
// The function validates the format, parses the slot, decodes the Bitcoin address,
// and verifies the checksum to ensure the integrity of the deposit address.
func DecodeDepositAddress(depositAddress string) (int64, btcutil.Address, string, error) {
	parts := strings.Split(depositAddress, "_")
	if len(parts) != 3 {
		return 0, nil, "", errors.New("invalid format, expected slot_address_checksum")
	}

	slot, err := strconv.ParseInt(parts[0], 10, 64)
	if err != nil || slot < 0 || slot > 254 {
		return 0, nil, "", fmt.Errorf("slot must be a whole number between 0 and 254: %w", err)
	}

	addressPart := parts[1]
	address, err := btcutil.DecodeAddress(addressPart, nil)
	if err != nil {
		return 0, nil, "", fmt.Errorf("address part is not a valid bitcoin address: %w", err)
	}

	addrWithoutChecksum := fmt.Sprintf("%d_%s_", slot, addressPart)
	hash := sha256.Sum256([]byte(addrWithoutChecksum))
	calculatedChecksum := hex.EncodeToString(hash[:3])
	checksum := parts[2]
	if checksum != calculatedChecksum {
		return 0, nil, "", fmt.Errorf("invalid checksum: expected %s, got %s", calculatedChecksum, checksum)
	}

	return slot, address, checksum, nil
}
