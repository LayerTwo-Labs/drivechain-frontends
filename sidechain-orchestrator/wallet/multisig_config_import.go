package wallet

import (
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// scriptTypeFromFormat maps a wallet-config address/format label (P2WSH,
// P2SH-P2WSH, P2SH) to the descriptor script-type string.
func scriptTypeFromFormat(s string) string {
	switch strings.ToUpper(strings.ReplaceAll(s, " ", "")) {
	case "P2SH":
		return "sh"
	case "P2SH-P2WSH", "P2WSH-P2SH":
		return "sh-wsh"
	case "P2TR":
		return "tr"
	default:
		return "wsh"
	}
}

// normalizeCosignerXpub rewrites a SLIP-0132 extended key (Zpub/Ypub/…) to its
// canonical xpub/tpub so parsed cosigners sort and store consistently.
func normalizeCosignerXpub(x string) (string, error) {
	canonical, _, _, err := normalizeExtendedKey(strings.TrimSpace(x))
	if err != nil {
		return "", err
	}
	return canonical, nil
}

func stripMasterPrefix(path string) string {
	return strings.TrimPrefix(strings.TrimPrefix(path, "m/"), "M/")
}

func isHexFingerprint(s string) bool {
	if len(s) != 8 {
		return false
	}
	_, err := hex.DecodeString(s)
	return err == nil
}

// parseColdcardConfig parses a Coldcard-style multisig text config:
//
//	Name: ...
//	Policy: 2 of 3
//	Derivation: m/48'/0'/0'/2'
//	Format: P2WSH
//	<XFP>: <xpub>
func parseColdcardConfig(content string) (m, n int, scriptType string, cosigners []MultisigCosigner, err error) {
	scriptType = "wsh"
	derivation := ""
	for _, line := range strings.Split(content, "\n") {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}
		key, val, found := strings.Cut(line, ":")
		if !found {
			continue
		}
		key = strings.TrimSpace(key)
		val = strings.TrimSpace(val)
		switch strings.ToLower(key) {
		case "policy":
			fields := strings.Fields(val) // "2 of 3"
			if len(fields) >= 3 {
				m, _ = strconv.Atoi(fields[0])
				n, _ = strconv.Atoi(fields[2])
			}
		case "derivation":
			derivation = stripMasterPrefix(val)
		case "format":
			scriptType = scriptTypeFromFormat(val)
		case "name":
			// display name only
		default:
			if isHexFingerprint(key) {
				xpub, nerr := normalizeCosignerXpub(val)
				if nerr != nil {
					continue // an 8-hex key whose value is not an xpub is not a cosigner line
				}
				cosigners = append(cosigners, MultisigCosigner{
					Xpub:        xpub,
					Fingerprint: strings.ToLower(key),
					OriginPath:  derivation,
				})
			}
		}
	}
	if len(cosigners) == 0 {
		return 0, 0, "", nil, errors.New("no cosigner keys found in config")
	}
	if n == 0 {
		n = len(cosigners)
	}
	if m < 1 || m > n {
		return 0, 0, "", nil, fmt.Errorf("invalid policy %d-of-%d", m, n)
	}
	if len(cosigners) != n {
		return 0, 0, "", nil, fmt.Errorf("policy declares %d cosigners but %d keys are listed", n, len(cosigners))
	}
	return m, n, scriptType, cosigners, nil
}

// parseMultisigJSON parses a Sparrow/Specter export (carries a descriptor) or a
// Caravan config (quorum + extendedPublicKeys).
func parseMultisigJSON(content string) (m, n int, scriptType string, cosigners []MultisigCosigner, err error) {
	var raw map[string]json.RawMessage
	if err := json.Unmarshal([]byte(content), &raw); err != nil {
		return 0, 0, "", nil, fmt.Errorf("parse json config: %w", err)
	}
	// Sparrow/Specter exports usually carry the output descriptor directly.
	for _, field := range []string{"descriptor", "recv_descriptor", "receive_descriptor"} {
		if v, ok := raw[field]; ok {
			var s string
			if json.Unmarshal(v, &s) == nil && strings.Contains(s, "(") {
				return ParseMultisigDescriptor(s)
			}
		}
	}
	if _, ok := raw["extendedPublicKeys"]; ok {
		return parseCaravanJSON(content)
	}
	return 0, 0, "", nil, errors.New("unrecognized JSON multisig config")
}

func parseCaravanJSON(content string) (m, n int, scriptType string, cosigners []MultisigCosigner, err error) {
	var cfg struct {
		AddressType string `json:"addressType"`
		Quorum      struct {
			RequiredSigners int `json:"requiredSigners"`
			TotalSigners    int `json:"totalSigners"`
		} `json:"quorum"`
		ExtendedPublicKeys []struct {
			XFP       string `json:"xfp"`
			Bip32Path string `json:"bip32Path"`
			Xpub      string `json:"xpub"`
		} `json:"extendedPublicKeys"`
	}
	if err := json.Unmarshal([]byte(content), &cfg); err != nil {
		return 0, 0, "", nil, fmt.Errorf("parse caravan config: %w", err)
	}
	scriptType = scriptTypeFromFormat(cfg.AddressType)
	for _, k := range cfg.ExtendedPublicKeys {
		xpub, nerr := normalizeCosignerXpub(k.Xpub)
		if nerr != nil {
			return 0, 0, "", nil, fmt.Errorf("cosigner %s: %w", k.XFP, nerr)
		}
		cosigners = append(cosigners, MultisigCosigner{
			Xpub:        xpub,
			Fingerprint: strings.ToLower(k.XFP),
			OriginPath:  stripMasterPrefix(k.Bip32Path),
		})
	}
	m, n = cfg.Quorum.RequiredSigners, cfg.Quorum.TotalSigners
	if n == 0 {
		n = len(cosigners)
	}
	if m < 1 || m > n || len(cosigners) != n {
		return 0, 0, "", nil, fmt.Errorf("invalid caravan config: %d-of-%d with %d keys", m, n, len(cosigners))
	}
	return m, n, scriptType, cosigners, nil
}
