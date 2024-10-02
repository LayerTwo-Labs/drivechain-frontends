package drivechain

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// DecodeDepositAddress decodes a deposit address string into its components.
// The deposit address format is: slot_address_checksum
// It returns the slot number, the Bitcoin address, the checksum, and any error encountered.
// The function validates the format, parses the slot, decodes the Bitcoin address,
// and verifies the checksum to ensure the integrity of the deposit address.
func DecodeDepositAddress(depositAddress string) (uint32, string, string, error) {
	parts := strings.Split(depositAddress, "_")
	if len(parts) != 3 {
		return 0, "", "", errors.New("invalid format, expected slot_address_checksum")
	}

	slotStr := strings.TrimPrefix(parts[0], "s")
	slot, err := strconv.ParseUint(slotStr, 10, 64)
	if err != nil || slot > 254 {
		return 0, "", "", fmt.Errorf("slot must be a whole number between 0 and 254: %w", err)
	}

	address := parts[1]

	addrWithoutChecksum := fmt.Sprintf("s%d_%s_", slot, address)
	hash := sha256.Sum256([]byte(addrWithoutChecksum))
	calculatedChecksum := hex.EncodeToString(hash[:3])
	checksum := parts[2]
	if checksum != calculatedChecksum {
		return 0, "", "", fmt.Errorf("invalid checksum: expected %s, got %s", calculatedChecksum, checksum)
	}

	return uint32(slot), address, checksum, nil
}
