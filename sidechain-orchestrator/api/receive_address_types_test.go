package api

import (
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

// The Receive tab asks for one of these, so a wallet must advertise only what
// it derives. A taproot wallet that reports segwit refuses every poll.
func TestReceiveAddressTypesFollowTheWallet(t *testing.T) {
	for _, tc := range []struct {
		name   string
		wallet wallet.WalletData
		want   []pb.AddressType
	}{
		{
			name:   "a hot segwit wallet derives both kinds",
			wallet: wallet.WalletData{WalletType: wallet.WalletTypeElectrum, ScriptType: "native-segwit"},
			want:   []pb.AddressType{pb.AddressType_ADDRESS_TYPE_SEGWIT, pb.AddressType_ADDRESS_TYPE_TAPROOT},
		},
		{
			name:   "a hot taproot wallet leads with taproot",
			wallet: wallet.WalletData{WalletType: wallet.WalletTypeElectrum, ScriptType: "taproot"},
			want:   []pb.AddressType{pb.AddressType_ADDRESS_TYPE_TAPROOT, pb.AddressType_ADDRESS_TYPE_SEGWIT},
		},
		{
			name: "an explicit path pins the wallet to one kind",
			wallet: wallet.WalletData{
				WalletType:     wallet.WalletTypeElectrum,
				ScriptType:     "taproot",
				DerivationPath: "m/86'/0'/0'",
			},
			want: []pb.AddressType{pb.AddressType_ADDRESS_TYPE_TAPROOT},
		},
		{
			name: "a wallet pinned to an explicit path derives that kind only",
			wallet: wallet.WalletData{
				WalletType:     wallet.WalletTypeElectrum,
				DerivationPath: wallet.EnforcerAccountPath,
			},
			want: []pb.AddressType{pb.AddressType_ADDRESS_TYPE_SEGWIT},
		},
	} {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, receiveAddressTypesProto(&tc.wallet))
		})
	}
}

// A multisig wallet's kind comes from its descriptor, and no AddressType names
// it. The Receive tab reads an empty list as "no choice to make".
func TestReceiveAddressTypesDropsAKindTheEnumOmits(t *testing.T) {
	w := wallet.WalletData{
		WalletType: wallet.WalletTypeElectrum,
		ScriptType: "multisig",
		Multisig:   &wallet.MultisigWalletData{M: 2, N: 3},
	}

	require.Empty(t, receiveAddressTypesProto(&w))
}
