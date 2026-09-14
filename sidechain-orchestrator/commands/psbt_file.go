package commands

import (
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/btcsuite/btcd/btcutil/psbt"
)

func readPSBTFile(path string) (string, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return "", fmt.Errorf("read the PSBT file: %w", err)
	}
	var packet *psbt.Packet
	if bytes.HasPrefix(raw, []byte{'p', 's', 'b', 't', 0xff}) {
		packet, err = psbt.NewFromRawBytes(bytes.NewReader(raw), false)
	} else {
		packet, err = psbt.NewFromRawBytes(strings.NewReader(strings.TrimSpace(string(raw))), true)
	}
	if err != nil {
		return "", fmt.Errorf("read the PSBT data: %w", err)
	}
	return packet.B64Encode()
}

func writePSBTFile(path, packet string) error {
	raw, err := base64.StdEncoding.DecodeString(packet)
	if err != nil {
		return fmt.Errorf("read the PSBT data: %w", err)
	}
	file, err := os.OpenFile(path, os.O_WRONLY|os.O_CREATE|os.O_EXCL, 0o600)
	if err != nil {
		return fmt.Errorf("create the PSBT file: %w", err)
	}
	_, writeErr := file.Write(raw)
	if err := errors.Join(writeErr, file.Close()); err != nil {
		return fmt.Errorf("write the PSBT file: %w", err)
	}
	return nil
}
