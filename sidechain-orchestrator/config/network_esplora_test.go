package config

import "testing"

// A wallet reads its thunder history from the hosted index, so a wrong URL
// leaves the history empty with no other sign.
func TestThunderEsploraURLForNetwork(t *testing.T) {
	if got := ThunderEsploraURLForNetwork(NetworkECash); got != "https://seed.beta.ecash.eu.com/thunder" {
		t.Errorf("ecash index = %q", got)
	}
	for _, n := range []Network{NetworkSignet, NetworkMainnet, NetworkRegtest} {
		if got := ThunderEsploraURLForNetwork(n); got != "" {
			t.Errorf("%s index = %q, want none hosted yet", n, got)
		}
	}
}

// The address explorer reads these chains from a hosted index, so a wrong URL
// leaves the address empty with no other sign.
func TestSidechainEsploraURLForNetwork(t *testing.T) {
	for chain, want := range map[string]string{
		"thunder":   "https://seed.beta.ecash.eu.com/thunder",
		"bitnames":  "https://seed.beta.ecash.eu.com/bitnames",
		"bitassets": "https://seed.beta.ecash.eu.com/bitassets",
		"photon":    "https://seed.beta.ecash.eu.com/photon",
		"coinshift": "https://seed.beta.ecash.eu.com/coinshift",
	} {
		if got := SidechainEsploraURLForNetwork(chain, NetworkECash); got != want {
			t.Errorf("%s ecash index = %q, want %q", chain, got, want)
		}
		for _, n := range []Network{NetworkSignet, NetworkMainnet, NetworkRegtest} {
			if got := SidechainEsploraURLForNetwork(chain, n); got != "" {
				t.Errorf("%s %s index = %q, want none hosted yet", chain, n, got)
			}
		}
	}
}

// A chain with no hosted index must answer empty, or the explorer would read
// another chain's coins.
func TestSidechainEsploraURLRefusesAnUnhostedChain(t *testing.T) {
	for _, chain := range []string{"truthcoin", "zside", "bbc", ""} {
		if got := SidechainEsploraURLForNetwork(chain, NetworkECash); got != "" {
			t.Errorf("%q index = %q, want none hosted", chain, got)
		}
	}
}

// Each eCash generation runs its own index box. A generation that reads the
// previous one's box would show another chain's history as this chain's.
func TestSidechainEsploraURLFollowsTheGeneration(t *testing.T) {
	original := ECashNetworkID()
	t.Cleanup(func() { SetECashNetworkID(original) })

	for generation, want := range map[string]string{
		"alphanet": "https://seed.alpha.ecash.eu.com/thunder",
		"betanet":  "https://seed.beta.ecash.eu.com/thunder",
		// Real ECX runs the bare host.
		"ecash": "https://seed.ecash.eu.com/thunder",
		// The retired series runs no box, and real ECX history under a test
		// fork would read as that fork's own.
		"drynet4": "",
		"drynet":  "",
	} {
		SetECashNetworkID(generation)
		if got := SidechainEsploraURLForNetwork("thunder", NetworkECash); got != want {
			t.Errorf("%s thunder index = %q, want %q", generation, got, want)
		}
		if got := ThunderEsploraURLForNetwork(NetworkECash); got != want {
			t.Errorf("%s thunder helper = %q, want %q", generation, got, want)
		}
	}
}

// The escrow index belongs to the mainchain, so it follows the generation too.
func TestDrivechainIndexURLFollowsTheGeneration(t *testing.T) {
	original := ECashNetworkID()
	t.Cleanup(func() { SetECashNetworkID(original) })

	for generation, want := range map[string]string{
		"alphanet": "https://seed.alpha.ecash.eu.com/drivechain",
		"betanet":  "https://seed.beta.ecash.eu.com/drivechain",
		"ecash":    "https://seed.ecash.eu.com/drivechain",
		"drynet4":  "",
	} {
		SetECashNetworkID(generation)
		if got := DrivechainIndexURLForNetwork(NetworkECash); got != want {
			t.Errorf("%s escrow index = %q, want %q", generation, got, want)
		}
	}
	SetECashNetworkID("alphanet")
	for _, n := range []Network{NetworkSignet, NetworkMainnet, NetworkRegtest} {
		if got := DrivechainIndexURLForNetwork(n); got != "" {
			t.Errorf("%s escrow index = %q, want none hosted", n, got)
		}
	}
}

// The split engine reads drivechain's own BTC explorer first, and the public
// explorers only when it fails.
func TestSplitCheckEsploraURLsReadDrivechainFirst(t *testing.T) {
	want := []string{
		"https://explorer.mainnet.drivechain.info/api",
		"https://mempool.space/api",
		"https://blockstream.info/api",
	}
	got := SplitCheckEsploraURLs()
	if len(got) != len(want) {
		t.Fatalf("split servers = %q, want %q", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Errorf("split server %d = %q, want %q", i, got[i], want[i])
		}
	}
}
