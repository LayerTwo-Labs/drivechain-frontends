package commands

import (
	"fmt"
	"io"
)

func writeTransactionWarning(writer io.Writer, message string) error {
	if message == "" {
		return nil
	}
	if _, err := fmt.Fprintf(writer, "Warning: %s\n", message); err != nil {
		return fmt.Errorf("write the transaction warning: %w", err)
	}
	return nil
}
