package addressbook

import (
	"strings"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/drivechain"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

var allChainParams = []*chaincfg.Params{
	&chaincfg.MainNetParams,
	&chaincfg.SigNetParams,
	&chaincfg.TestNet3Params,
	&chaincfg.RegressionNetParams,
}

// ClassifyAddress inspects the input string and returns the address type it
// represents. Pure function — no DB, no network — so it is safe to call on
// every read of ListAddressBook. Returns ADDRESS_TYPE_UNKNOWN if nothing
// matches and ADDRESS_TYPE_UNSPECIFIED for the empty string.
//
// Ordering (cheapest → most expensive):
//  1. BIP47 v1 spec payment code: base58check-decode succeeds with version
//     byte 0x47 and an 80-byte payload that parses as a valid payment code.
//  2. Drivechain deposit: strict 3-part s<slot>_<addr>_<checksum> with
//     valid checksum and an embedded L1 address that decodes on some net.
//  3. Bitcoin L1 on any of mainnet / signet / testnet3 / regtest.
func ClassifyAddress(s string) pb.AddressType {
	s = strings.TrimSpace(s)
	if s == "" {
		return pb.AddressType_ADDRESS_TYPE_UNSPECIFIED
	}

	if _, err := bip47.ParsePaymentCode(s); err == nil {
		return pb.AddressType_ADDRESS_TYPE_BIP47_PAYMENT_CODE
	}

	if strings.Count(s, "_") == 2 {
		slot, addr, checksum, err := drivechain.DecodeDepositAddress(s)
		if err == nil && slot != nil && checksum != nil {
			if decodeL1Any(addr) {
				return pb.AddressType_ADDRESS_TYPE_DRIVECHAIN_DEPOSIT
			}
		}
	}

	if decodeL1Any(s) {
		return pb.AddressType_ADDRESS_TYPE_BITCOIN_L1
	}

	return pb.AddressType_ADDRESS_TYPE_UNKNOWN
}

func decodeL1Any(s string) bool {
	for _, p := range allChainParams {
		if _, err := btcutil.DecodeAddress(s, p); err == nil {
			return true
		}
	}
	return false
}
