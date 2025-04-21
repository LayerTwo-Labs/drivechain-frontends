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
// It can handle three formats:
// 1. Just a address (e.g. "13tqn1jxdcrbDycej4bp5S5PcffYtdGNPy")
// 2. Slot and address (e.g. "s9_13tqn1jxdcrbDycej4bp5S5PcffYtdGNPy")
// 3. Full format with checksum (e.g. "s9_13tqn1jxdcrbDycej4bp5S5PcffYtdGNPy_checksum")
// Returns slot number (or 0), address, checksum (or empty), and any error.
func DecodeDepositAddress(depositAddress string) (*int64, string, *string, error) {
	parts := strings.Split(depositAddress, "_")

	// Case 1: Just Bitcoin address
	if len(parts) == 1 {
		return nil, depositAddress, nil, nil
	}

	// Case 2: Slot and address
	if len(parts) == 2 {
		slotStr := strings.TrimPrefix(parts[0], "s")
		slot, err := strconv.ParseInt(slotStr, 10, 64)
		if err != nil || slot < 0 || slot > 254 {
			return nil, "", nil, fmt.Errorf("slot must be a whole number between 0 and 254: %w", err)
		}
		return &slot, parts[1], nil, nil
	}

	// Case 3: Full format with checksum
	if len(parts) == 3 {
		slotStr := strings.TrimPrefix(parts[0], "s")
		slot, err := strconv.ParseInt(slotStr, 10, 64)
		if err != nil || slot < 0 || slot > 254 {
			return nil, "", nil, fmt.Errorf("slot must be a whole number between 0 and 254: %w", err)
		}

		address := parts[1]
		checksum := parts[2]

		addrWithoutChecksum := fmt.Sprintf("s%d_%s_", slot, address)
		hash := sha256.Sum256([]byte(addrWithoutChecksum))
		calculatedChecksum := hex.EncodeToString(hash[:3])

		if checksum != calculatedChecksum {
			return &slot, address, nil, nil
		}

		return &slot, address, &checksum, nil
	}

	return nil, "", nil, errors.New("could not parse deposit address: invalid format")
}
