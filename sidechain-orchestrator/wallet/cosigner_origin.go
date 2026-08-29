package wallet

import (
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
)

// CheckCosignerKeyMatchesOrigin makes sure a cosigner key belongs at the path
// the wallet records for it. A key and a path that disagree build a correct
// script with a wrong label, and a hardware signer then derives a key the
// script does not hold and signs for it. The depth of an extended key counts
// the steps from the master, so it must equal the length of the origin path.
func CheckCosignerKeyMatchesOrigin(xpub, originPath string) error {
	trimmed := strings.TrimSpace(xpub)
	if trimmed == "" {
		return nil
	}
	steps, err := countPathSteps(originPath)
	if err != nil {
		return err
	}
	// A cosigner pasted as a bare xpub gives no origin, so it claims no
	// derivation, and no path contradicts its depth.
	if steps == 0 {
		return nil
	}
	key, err := hdkeychain.NewKeyFromString(trimmed)
	if err != nil {
		return fmt.Errorf("read the cosigner key: %w", err)
	}
	if int(key.Depth()) == steps {
		return nil
	}
	return fmt.Errorf(
		"the cosigner key sits %d steps from its master key, and the origin %s names %d; the key does not come from that path, so a hardware signer derives a key this wallet does not hold",
		key.Depth(), displayOrigin(originPath), steps)
}

// countPathSteps counts the elements of an origin path, with or without the
// leading "m/".
func countPathSteps(originPath string) (int, error) {
	path, ok := parseOriginPath(originPath)
	if !ok {
		return 0, fmt.Errorf("the origin path %q is not a derivation path", originPath)
	}
	return len(path), nil
}

func displayOrigin(originPath string) string {
	p := strings.Trim(strings.TrimSpace(originPath), "/")
	if p == "" {
		return "m"
	}
	if strings.HasPrefix(p, "m/") {
		return p
	}
	return "m/" + p
}
