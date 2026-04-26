package api

import (
	"strings"
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
		true, false, true, nil,
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
		[]wallet.WalletData{enforcer}, enforcer.ID, true, false, true, nil,
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

// TestBuildWatchWalletDataResponseBip47Populated guards against the
// receive-tab spinner regression: any wallet with a SeedHex must publish a
// non-empty bip47_payment_code, otherwise the loader hangs forever.
func TestBuildWatchWalletDataResponseBip47Populated(t *testing.T) {
	now := time.Now().UTC()
	hot := wallet.WalletData{
		ID:         "hot-id",
		Name:       "Hot",
		WalletType: walletTypeEnforcer,
		CreatedAt:  now,
		// 64-byte seed (deterministic test vector).
		Master: wallet.MasterWallet{
			SeedHex: "0937ba268f2cc405562d1ae9d25573744897ee5e826873317756fef36557acda1126fc3c56870ab263b1e4b59da9674d943f4ad34b8d7981fc38cc9cae6baa84",
		},
	}
	watchOnly := wallet.WalletData{
		ID:         "watch-id",
		Name:       "Watch",
		WalletType: "watchOnly",
		CreatedAt:  now,
		Master:     wallet.MasterWallet{SeedHex: ""},
	}

	resp := buildWatchWalletDataResponse(
		[]wallet.WalletData{hot, watchOnly},
		hot.ID, true, false, true, nil,
	)

	var hotMd, watchMd string
	for _, w := range resp.GetWallets() {
		switch w.GetId() {
		case hot.ID:
			hotMd = w.GetBip47PaymentCode()
		case watchOnly.ID:
			watchMd = w.GetBip47PaymentCode()
		}
	}

	if hotMd == "" {
		t.Errorf("hot wallet must have a non-empty BIP47 payment code")
	}
	if !strings.HasPrefix(hotMd, "PM") {
		t.Errorf("BIP47 payment code expected to start with 'PM', got %q", hotMd)
	}
	if watchMd != "" {
		t.Errorf("watch-only wallet must not have a BIP47 payment code, got %q", watchMd)
	}
}

// TestBuildWatchWalletDataResponseBip47ErrorSurfaces ensures derivation
// errors reach the supplied callback rather than silently turning into the
// "" value that the UI treats as still-loading.
func TestBuildWatchWalletDataResponseBip47ErrorSurfaces(t *testing.T) {
	bad := wallet.WalletData{
		ID:         "bad-id",
		WalletType: walletTypeEnforcer,
		Master:     wallet.MasterWallet{SeedHex: "not-hex-zzz"},
	}
	var seenID string
	var seenErr error
	cb := func(id string, err error) { seenID = id; seenErr = err }

	resp := buildWatchWalletDataResponse(
		[]wallet.WalletData{bad}, bad.ID, true, false, true, cb,
	)

	if resp.GetWallets()[0].GetBip47PaymentCode() != "" {
		t.Errorf("malformed seed must yield empty payment code")
	}
	if seenErr == nil {
		t.Fatal("malformed seed must invoke the error callback")
	}
	if seenID != bad.ID {
		t.Errorf("error callback got wrong wallet id: %q", seenID)
	}
}

// TestBuildWatchWalletDataResponseLegacyWalletTypeStarters verifies that
// legacy wallets with walletType="" (created before the field existed) get
// stamped with starter material the same way enforcer wallets do, after
// loadWalletFile's backfill runs. We emulate that backfill here by setting
// walletType="enforcer" explicitly — the regression we're guarding against
// is the response code dropping starter material from any wallet with a
// non-default walletType, which would re-empty the Starters tab.
func TestBuildWatchWalletDataResponseLegacyWalletTypeStarters(t *testing.T) {
	legacy := wallet.WalletData{
		ID:         "legacy",
		WalletType: walletTypeEnforcer, // post-backfill
		Master:     wallet.MasterWallet{Mnemonic: "legacy master"},
		L1:         wallet.L1Wallet{Mnemonic: "legacy l1"},
		Sidechains: []wallet.SidechainWallet{{Slot: 9, Name: "Thunder", Mnemonic: "legacy-side"}},
	}
	resp := buildWatchWalletDataResponse(
		[]wallet.WalletData{legacy}, legacy.ID, true, false, true, nil,
	)
	w := resp.GetWallets()[0]
	if w.GetMasterMnemonic() != "legacy master" {
		t.Errorf("master mnemonic missing: %q", w.GetMasterMnemonic())
	}
	if w.GetL1Mnemonic() != "legacy l1" {
		t.Errorf("L1 mnemonic missing: %q", w.GetL1Mnemonic())
	}
	if len(w.GetSidechains()) != 1 {
		t.Errorf("sidechain starter dropped")
	}
}
