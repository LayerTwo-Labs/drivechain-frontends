package wallet

// ECXBurnAddress receives Alphanet coins for an ECX claim.
const ECXBurnAddress = "1BitcoinEaterAddressDontSendf59kuE"

// ECXBurnScriptHex is the output script for ECXBurnAddress.
const ECXBurnScriptHex = "76a914759d6677091e973b9e9d99f19c68fbf43e3f05f988ac"

// ECXBurnMinimumSats is the lowest burn this claim accepts, in Alphanet satoshis.
const ECXBurnMinimumSats int64 = 100_000_000_000

// ECXCreditSats returns ceil(burnSats / 100) in ECX satoshis.
func ECXCreditSats(burnSats int64) int64 {
	credit := burnSats / 100
	if burnSats%100 > 0 {
		credit++
	}
	return credit
}
