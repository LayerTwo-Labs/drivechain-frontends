package orchestrator

import "errors"

// The legacy identifier is also a protobuf enum and an on-disk directory name.
// Do not confuse its July Signet package with the current slot-24 Alpha node.
const elementsSetupUnavailable = "Elements Alpha setup is unavailable: the published elements-bf8e9e1e package is not the current Alpha node. A verified Alpha release and authenticated parent/enforcer integration are required; see docs/elements-alpha-setup.md"

func checkElementsSetup(config BinaryConfig) error {
	if config.Name == "liquid-signet" {
		return errors.New(elementsSetupUnavailable)
	}
	return nil
}
