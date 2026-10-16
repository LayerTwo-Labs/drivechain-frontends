package addressbook

import (
	"strings"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/samber/lo"

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

// ClassifyAddress gives ADDRESS_TYPE_UNSPECIFIED for an empty string and
// ADDRESS_TYPE_UNKNOWN when no type matches.
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
	return lo.ContainsBy(allChainParams, func(p *chaincfg.Params) bool {
		_, err := btcutil.DecodeAddress(s, p)
		return err == nil
	})
}
