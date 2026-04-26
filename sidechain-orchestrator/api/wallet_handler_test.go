package api

import (
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestBuildWatchWalletDataResponseStartersAttachToEnforcer(t *testing.T) {
	now := time.Now().UTC()
	enforcer := wallet.WalletData{
		ID:         "enf-id",
		Name:       "Enforcer",
		WalletType: walletTypeEnforcer,
		CreatedAt:  now,
		Master:     wallet.MasterWallet{Mnemonic: "enforcer master mnemonic", SeedHex: ""},
		L1:         wallet.L1Wallet{Mnemonic: "enforcer l1 mnemonic"},
		Sidechains: []wallet.SidechainWallet{
			{Slot: 9, Name: "Thunder", Mnemonic: "thunder-starter"},
			{Slot: 5, Name: "BitNames", Mnemonic: "bitnames-starter"},
		},
	}
	core := wallet.WalletData{
		ID:         "core-id",
		Name:       "Core",
		WalletType: "bitcoinCore",
		CreatedAt:  now,
		Master:     wallet.MasterWallet{Mnemonic: "core master mnemonic"},
		L1:         wallet.L1Wallet{Mnemonic: "core l1 mnemonic"},
		Sidechains: []wallet.SidechainWallet{
			{Slot: 9, Name: "Thunder", Mnemonic: "core-side-starter"},
		},
	}

	resp := buildWatchWalletDataResponse(
		[]wallet.WalletData{enforcer, core},
		core.ID, // active wallet is the Core wallet, NOT the enforcer
		true, false, true,
	)

	if got := resp.GetActiveWalletId(); got != core.ID {
		t.Fatalf("active id: got %q, want %q", got, core.ID)
	}
	if len(resp.GetWallets()) != 2 {
		t.Fatalf("want 2 wallets, got %d", len(resp.GetWallets()))
	}

	var enf, c *struct {
		L1             string
		MasterMnemonic string
		Sides          int
	}
	for _, w := range resp.GetWallets() {
		entry := &struct {
			L1             string
			MasterMnemonic string
			Sides          int
		}{
			L1:             w.GetL1Mnemonic(),
			MasterMnemonic: w.GetMasterMnemonic(),
			Sides:          len(w.GetSidechains()),
		}
		switch w.GetId() {
		case enforcer.ID:
			enf = entry
		case core.ID:
			c = entry
		default:
			t.Fatalf("unexpected wallet id %q", w.GetId())
		}
	}

	if enf == nil || c == nil {
		t.Fatal("missing wallet metadata in response")
	}

	if enf.L1 != enforcer.L1.Mnemonic {
		t.Errorf("enforcer L1: got %q, want %q", enf.L1, enforcer.L1.Mnemonic)
	}
	if enf.MasterMnemonic != enforcer.Master.Mnemonic {
		t.Errorf("enforcer master: got %q, want %q", enf.MasterMnemonic, enforcer.Master.Mnemonic)
	}
	if enf.Sides != len(enforcer.Sidechains) {
		t.Errorf("enforcer sidechains: got %d, want %d", enf.Sides, len(enforcer.Sidechains))
	}

	if c.L1 != "" || c.MasterMnemonic != "" || c.Sides != 0 {
		t.Errorf("core wallet must not carry starter material: %+v", c)
	}
}

func TestBuildWatchWalletDataResponseEnforcerSidechainsRoundTrip(t *testing.T) {
	now := time.Now().UTC()
	enforcer := wallet.WalletData{
		ID:         "enf",
		WalletType: walletTypeEnforcer,
		CreatedAt:  now,
		Sidechains: []wallet.SidechainWallet{
			{Slot: 9, Name: "Thunder", Mnemonic: "thunder"},
			{Slot: 5, Name: "BitNames", Mnemonic: "bitnames"},
		},
	}

	resp := buildWatchWalletDataResponse(
		[]wallet.WalletData{enforcer}, enforcer.ID, true, false, true,
	)

	w := resp.GetWallets()[0]
	if len(w.GetSidechains()) != 2 {
		t.Fatalf("want 2 sidechains, got %d", len(w.GetSidechains()))
	}
	bySlot := map[int32]string{}
	for _, sc := range w.GetSidechains() {
		bySlot[sc.GetSlot()] = sc.GetMnemonic()
	}
	if bySlot[9] != "thunder" || bySlot[5] != "bitnames" {
		t.Errorf("sidechain mnemonics not preserved: %+v", bySlot)
	}
}
