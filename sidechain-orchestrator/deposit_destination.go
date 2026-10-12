package orchestrator

import (
	"errors"
	"fmt"
)

// MaxDepositDestinationLen is the longest deposit destination in bytes, the
// standard OP_RETURN data limit.
const MaxDepositDestinationLen = 80

// CheckDepositDestination returns an error when destination cannot be a
// sidechain deposit address: empty, longer than MaxDepositDestinationLen, or
// with a character outside ASCII letters, digits and '_'.
func CheckDepositDestination(destination string) error {
	if destination == "" {
		return errors.New("deposit address is empty")
	}
	if len(destination) > MaxDepositDestinationLen {
		return fmt.Errorf("deposit address is %d bytes, the limit is %d", len(destination), MaxDepositDestinationLen)
	}
	for i := 0; i < len(destination); i++ {
		if !depositDestinationByte(destination[i]) {
			return fmt.Errorf("deposit address holds %q at position %d, only letters, digits and '_' are allowed",
				destination[i], i)
		}
	}
	return nil
}

func depositDestinationByte(b byte) bool {
	return b >= 'a' && b <= 'z' || b >= 'A' && b <= 'Z' || b >= '0' && b <= '9' || b == '_'
}
