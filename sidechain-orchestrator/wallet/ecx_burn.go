package wallet

// ECXBurnAddress receives Alphanet or Betanet coins for an ECX claim.
const ECXBurnAddress = "1BitcoinEaterAddressDontSendf59kuE"

// ECXBurnScriptHex is the output script for ECXBurnAddress.
const ECXBurnScriptHex = "76a914759d6677091e973b9e9d99f19c68fbf43e3f05f988ac"

// ECXBurnMinimumSats is the lowest burn this claim accepts, in satoshis of the burn network.
const ECXBurnMinimumSats int64 = 100_000_000_000

// ECXBurnNetwork is an eCash network that accepts the burn.
type ECXBurnNetwork struct {
	Name string
	// CreditDivisor is the number of burn satoshis for one ECX satoshi.
	CreditDivisor int64
}

// ECXBurnNetworkByID returns the burn network for an eCash network id. Name is "" for each other id.
func ECXBurnNetworkByID(id string) ECXBurnNetwork {
	switch id {
	case "alphanet":
		return ECXBurnNetwork{Name: "Alphanet", CreditDivisor: 100}
	case "betanet":
		return ECXBurnNetwork{Name: "Betanet", CreditDivisor: 50}
	}
	return ECXBurnNetwork{}
}

// CreditSats returns ceil(burnSats / CreditDivisor) in ECX satoshis.
func (n ECXBurnNetwork) CreditSats(burnSats int64) int64 {
	credit := burnSats / n.CreditDivisor
	if burnSats%n.CreditDivisor > 0 {
		credit++
	}
	return credit
}
